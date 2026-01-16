import argparse, json, os, platform, re, signal, socket, subprocess, sys, time
import boto3
import botocore.session
import pyperclip

# reworking of my old tunneler.py script to use SSM instead

# 3. put into github
# 4. rest of configs

def die(msg):
    print(f"FATAL: {msg}")
    sys.exit(1)

FORWARDING_DOC = "AWS-StartPortForwardingSessionToRemoteHost"

class SsmTunneler:
    def __init__(self, env_name, cfg_filename):
        self.env_name = env_name

        self.cfg = self.load_cfg(cfg_filename)
        self.environments = self.cfg.get("environments", {})

        self.env = self.environments.get(self.env_name)
        # print(f"SsmTunneler running for '{self.env_name}'...")# / {self.env}...")

        smp_probe = self.cfg.get("session_manager_plugin")
        if smp_probe is None:
            if platform.system() == "Windows":
                self.session_mgr_plugin = "C:/Program Files/Amazon/SessionManagerPlugin/bin/session-manager-plugin.exe"
            else:
                self.session_mgr_plugin = "/usr/local/bin/session-manager-plugin"

            if not os.path.isfile(self.session_mgr_plugin):
                die(f"AWS Session Manager Plugin not found at expected location {self.session_mgr_plugin}; please ensure it is installed or if necessary, set config file value \"session_manager_plugin\" with correct location")
        else:
            self.session_mgr_plugin = smp_probe

            if not os.path.isfile(self.session_mgr_plugin):
                die(f"AWS Session Manager Plugin not found at supplied location {self.session_mgr_plugin}; please ensure it is installed or if necessary, set config file value \"session_manager_plugin\" with correct location")

    def load_cfg(self, filename):
        if filename is None:
            filename = os.environ.get("SSM_TUNNELER_CFG")

        if filename is None:
            die("Must either specify -c or set env variable SSM_TUNNELER_CFG to point to environments JSON definition")

        with open(filename) as f_in:
            return json.load(f_in)

    def aws_whoami(self):
        sts = boto3.client("sts")

        try:
            identity = sts.get_caller_identity()
            # user_id = identity["UserId"]
            # account = identity["Account"]
            return identity
        except Exception as e:
            if "InvalidClientTokenId" in str(e):
                pass

        return None

    def do_work(self):
        tunneler.check_sso_state()

        self.ssm_client = boto3.client("ssm")
        tunnels_opened = self.start_tunnels()

        if tunnels_opened > 0:
            while True:
                print(f"Still listening for '{self.env_name}' connections...")
                time.sleep(30)
        else:
            print(f"\nNo tunnels opened. Exiting.")


    # returns dictionary of open sessions
    # top level keys are environment names
    # second level keys are destination descriptors
    def check_open_sessions(self):
        resp = self.ssm_client.describe_sessions(State="Active")
        open_sessions = {}

        open_sessions_list = resp.get("Sessions", [])

        reason_match = f"'({os.getlogin()} @ {socket.gethostname()})' *'(.*)' *tunnel for '(.*)' environment"
        for s in open_sessions_list:
            target = s.get("Target")
            doc = s.get("DocumentName")
            reason = s.get("Reason")
            # print(f"found open session reason {reason}")

            if target == self.env["ssm"]["bastion_target"] and doc == FORWARDING_DOC:
                match = re.search(reason_match, reason)
                if match:
                    who_opened = match.group(1)
                    destination_descriptor = match.group(2)
                    environment_name = match.group(3)
                    open_sessions.setdefault(environment_name, {})
                    open_sessions[environment_name][destination_descriptor] = s

        return open_sessions


    """
    e.g.
    aws ssm start-session \
        --target <ec2_instance_id> \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters '{"host":["RDS.hostname.aws"],"portNumber":["5432"], "localPortNumber":["8432"]}'
    """
    def start_tunnels(self):
        open_sessions = self.check_open_sessions()

        hostname = socket.gethostname()

        num_sessions_opened = 0
        for d in self.env["destinations"]:
            session_probe = open_sessions.get(self.env_name, {}).get(d['descriptor'])
            if session_probe:
                print(f"tunnel session for {self.env_name} / {d['descriptor']} already exists: session id '{session_probe.get('SessionId')}'")
            else:
                print(f"opening tunnel via SSM for {self.env_name} / {d['descriptor']}")

                reason = f"'{os.getlogin()} @ {socket.gethostname()}' '{d['descriptor']}' tunnel for '{self.env_name}' environment"
                params = {
                    "host": [ d["host"] ],
                    "portNumber": [ str(d["port"]) ],
                    "localPortNumber": [ str(d["tunnel_port"]) ],
                }

                response = self.ssm_client.start_session(
                    Target=self.env["ssm"]["bastion_target"],
                    DocumentName=FORWARDING_DOC,
                    Reason=reason,
                    Parameters=params,
                )

                # print(f"opened session id '{response['SessionId']}'")
                # print(response)

                # see https://stackoverflow.com/questions/62679706/how-to-use-boto3-ssm-client-to-create-port-forwarding-session
                # and https://stackoverflow.com/questions/66222667/how-to-use-session-manager-plugin-command/70311671#70311671

                # start_session doesn't last long -- we need to pass that along to the session
                # manager plugin (which I can find no documentation for but this seems to work!)

                region = self.target_profile_data["region"]
                cmd = [
                    self.session_mgr_plugin,
                    json.dumps(response),
                    region,
                    'StartSession',
                    'default',  # profile name from aws credentials/config files
                    json.dumps(dict(Target=self.env["ssm"]["bastion_target"])),
                    f"https://ssm.{region}.amazonaws.com"  # endpoint for ssm service
                ]
                process = subprocess.Popen(
                    cmd,
                    stdout=None,
                    stderr=None
                )
                num_sessions_opened += 1

        return num_sessions_opened


    def force_external_sso_login(self, context):
        print(f"----------")
        print(f"You are not set up to use the expected sso profile for this operation.")
        print(context)
        print(f"Try e.g. (this works on Tom's computer as he has a bash function setup for this):\n")
        cmd = f"aws_sso_login {self.env['ssm']['sso_session']}"

        print(f"{cmd}\n")

        print(f"This command has been copied to system clipboard.")
        pyperclip.copy(cmd)

        sys.exit(1)

    # each environment requires us to be AWS SSO'ed in; let's check it
    def check_sso_state(self):
        # h/t https://stackoverflow.com/questions/67115460/using-boto3-to-get-aws-configuration-option
        session = botocore.session.Session()
        profiles_config = session.full_config.get("profiles", {})
        sso_sessions_config = session.full_config.get("sso_sessions", {})

        if self.env is not None:
            required_sso_session_name = self.env.get("ssm", {}).get("sso_session")

            if required_sso_session_name is not None:
                # print(f"checking SSO state for environment '{self.env_name}', sso session '{required_sso_session_name}'...")

                self.target_profile_data = None
                for profile_name in profiles_config:
                    profile_data = profiles_config[profile_name]
                    if profile_data.get("sso_session") == required_sso_session_name:
                        self.target_profile_data = profile_data
                        break

                if self.target_profile_data is not None:
                    identity = self.aws_whoami()

                    if identity is None:
                        # you're not logged in anywhere
                        self.force_external_sso_login("(You don't currently have any AWS credentials in this context.)")
                    else:
                        search_for = f"arn:aws:sts.*:{self.target_profile_data['sso_account_id']}:assumed-role/AWSReservedSSO_{self.target_profile_data['sso_role_name']}_.*"

                        if re.search(search_for, identity['Arn']):
                            # you're authenticated on the right profile
                            pass
                        else:
                            # you're authenticated -- but not on the right profile
                            self.force_external_sso_login(f"(You're authenticated as user id {identity.get('UserId')} on account {identity.get('Account')})")
                else:
                    die(f"Could not find SSO session name '{required_sso_session_name}'; check your ~/.aws/config and your ssm_tunneler.py configuration")
        else:
            legal_environments = [ f"'{k}'" for k in self.environments ]
            die(f"Bad parameter value for '-e {self.env_name}' [legal values are: {', '.join(legal_environments)}]")

    def cleanup(self):
        print(f"Performing cleanup tasks!")
        sys.exit(0)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="V2 Tunneler")
    parser.add_argument("-c", "--cfg", type=str, help="cfg file containing environment efinitions")
    parser.add_argument("-e", "--env", type=str, help="environment to work on", required=True)
    args = parser.parse_args()

    tunneler = SsmTunneler(args.env, args.cfg)

    def signal_handler(sig, frame):
        tunneler.cleanup()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    tunneler.do_work()
