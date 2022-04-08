#! /usr/bin/env python

import sys, getopt, subprocess

try:
    import psutil
except:
    print("Command failed; did you activate the correct Python virtual environment?")
    print("e.g. 'workon tunneler'")
    sys.exit(1)

# python script I use for opening/closing/monitoring tunnels
# as an alternative to having a billion things in icf.bash

# alias tunnel_litstream_dev2021_start="autossh -M 20065 -N -f -L 2432:litstream-dev2021-pg.c5vzduwbgj5d.us-east-1.rds.amazonaws.com:5432 -L 9744:litstream-dev2021-elcache.nbwrk0.0001.use1.cache.amazonaws.com:6379 dev2021_jumpbox"
# alias tunnel_litstream_dev2021_stop="stopTunnelling.sh 2432:litstream-dev2021-pg"
# alias redis_litstream_dev2021="redis-cli -h localhost -p 9744"

# 2021 suffixes are for the old account -- plain old dev/prod are the new Managed Services account

environments = {
    "dev": {
        "description": "New Managed Services dev environment, set up in Jan 2022",
        "postgres": "litstream-dev-pg.cf6dwigysdv2.us-east-1.rds.amazonaws.com:5432",
        "elasticache": "litstream-dev-elcache.4kd8tg.0001.use1.cache.amazonaws.com:6379",
        "jumpbox": "dev_jumpbox",
        "pg_tunnel_port": 3432,
        "elasticache_tunnel_port": 9750
    },
    "prod": {
        "description": "New Managed Services prod environment, set up in Dec 2021",
        "postgres": "litstream-prod-pg.c42oobxvr0vm.us-east-1.rds.amazonaws.com:5432",
        "elasticache": "litstream-prod-elcache.lqsovj.0001.use1.cache.amazonaws.com:6379",
        "jumpbox": "prod_jumpbox",
        "pg_tunnel_port": 4432,
        "elasticache_tunnel_port": 9752
    },
    "sandbox": {
        "description": "sandbox (developer works-in-progress) db on new Managed Services staging account, set up in March 2022",
        "postgres": "litstream-sandbox-pg.cf6dwigysdv2.us-east-1.rds.amazonaws.com:5432",
        "elasticache": "litstream-sandbox-elcache.4kd8tg.0001.use1.cache.amazonaws.com:6379",
        "jumpbox": "dev_jumpbox",
        "pg_tunnel_port": 8432,
        "elasticache_tunnel_port": 9736
    },
    # "sandbox2021": {
        # "description": "sandbox (developer works-in-progress) db from old account. Need to move to Managed Services!",
        # "postgres": "dragon-sandbox.c5vzduwbgj5d.us-east-1.rds.amazonaws.com:5432",
        # "elasticache": "litstream-sandbox-elcache-003.nbwrk0.0001.use1.cache.amazonaws.com:6379",
        # "jumpbox": "superolddev_jumpbox",
        # "pg_tunnel_port": 7432,
        # "elasticache_tunnel_port": 9760
    # },
    # "dev2021": {
        # "postgres": "litstream-dev2021-pg.c5vzduwbgj5d.us-east-1.rds.amazonaws.com:5432",
        # "elasticache": "litstream-dev2021-elcache.nbwrk0.0001.use1.cache.amazonaws.com:6379",
        # "jumpbox": "dev2021_jumpbox",
        # "pg_tunnel_port": 2432,
        # "elasticache_tunnel_port": 9744
    # },
    # "prod2021": {
        # "postgres": "litstream-prod2021-pg.c5vzduwbgj5d.us-east-1.rds.amazonaws.com:5432",
        # "elasticache": "litstream-prod2021-elcache.nbwrk0.0001.use1.cache.amazonaws.com:6379",
        # "jumpbox": "prod2021_jumpbox",
        # "pg_tunnel_port": 1432,
        # "elasticache_tunnel_port": 9742
    # },
    "embsi_prod": {
        "postgres": "emut-prod-psql.c9bgatqk4une.us-east-1.rds.amazonaws.com:5432",
        "jumpbox": "prod_embsi_jumpbox",
        "pg_tunnel_port": 6472,
    }
}

MONITOR_PORT_START = 20000

class TunnelUtil(object):
    operation = None
    env_name = ""
    env = None

    def __init__(self, o, e):
        self.operation = o
        self.env_name = e
        self.env = environments.get(e)

    def get_running_tunnels(self):
        tunnels = []
        for process in psutil.process_iter():
            process_as_string = str(process)
            if "autossh" in process_as_string:
                # print(f"RUNNING {process.cmdline()}")
                tunnels.append(process)

        return tunnels

    def find_running_tunnel(self, pg_clause):
        for tunnel in self.running_tunnels:
            cmds = tunnel.cmdline()
            if pg_clause in cmds:
                return tunnel
        return None

    def get_available_monitor_port(self):
        monitor_ports = []
        for tunnel in self.running_tunnels:
            cmds = tunnel.cmdline()
            monitor_ports.append(int(cmds[2]))

        monitor_ports.sort()

        probe_port = MONITOR_PORT_START

        while True:
            if probe_port not in monitor_ports:
                return probe_port
            else:
                probe_port += 5

    def do_work(self):
        self.running_tunnels = self.get_running_tunnels()

        pg_tunnel_clause = None
        elasticache_tunnel_clause = None

        if self.operation != "check_tunnels":
            pg_tunnel_clause = f"{self.env['pg_tunnel_port']}:{self.env['postgres']}"

            elasticache = self.env.get('elasticache')
            elasticache_tunnel_clause = f"{self.env['elasticache_tunnel_port']}:{self.env['elasticache']}" if elasticache is not None else ""

        if self.operation == "start_tunnel":
            if self.find_running_tunnel(pg_tunnel_clause) is not None:
                print(f"The {self.env_name} tunnel is already open.")
            else:
                # build the command
                available_monitor_port = self.get_available_monitor_port()
                """
                cmd = [
                    "autossh",
                    "-M", str(available_monitor_port),
                    "-N", "-f",
                    "-L", pg_tunnel_clause,
                    "-L", elasticache_tunnel_clause,
                    self.env["jumpbox"]
                ]
                """
                cmd = [
                    "autossh",
                    "-M", str(available_monitor_port),
                    "-N", "-f",
                    "-L", pg_tunnel_clause,
                ]
                if elasticache_tunnel_clause != "":
                    cmd.append("-L")
                    cmd.append(elasticache_tunnel_clause)

                cmd.append(self.env["jumpbox"])

                subprocess.run(cmd)
                print(" ".join(cmd))
                print(f"{self.env_name} tunnel opened!")
        elif self.operation == "stop_tunnel":
            running_tunnel = self.find_running_tunnel(pg_tunnel_clause)
            if running_tunnel is None:
                print(f"The {self.env_name} tunnel is not currently running.")
            else:
                cmd = [
                    "kill", str(running_tunnel.pid)
                ]
                subprocess.run(cmd)
                print(f"{self.env_name} tunnel closed!")
        elif self.operation == "check_tunnels":
            running_tunnel_names = []

            for env_name in environments:
                env = environments[env_name]
                loop_pg_tunnel_clause = f"{env['pg_tunnel_port']}:{env['postgres']}"
                running_tunnel = self.find_running_tunnel(loop_pg_tunnel_clause)

                if running_tunnel is not None:
                    running_tunnel_names.append(env_name)

            if len(running_tunnel_names) > 0:
                readable_names = [f"'{x}'" for x in running_tunnel_names]
                print(f"Tunnels are currently opened for litstream {', '.join(readable_names)}")
            else:
                print("No tunnels are currently open.")
        else:
            print(f"operation '{self.operation}' is valid but not yet implemented")

def usage():
    legal_environments = ", ".join([f"'{x}'" for x in environments.keys()])
    print("Usage: tunneler.py -o <operation> -e <environment>")
    print(f"Environment can be {legal_environments}")
    print("Operation can be 'check_tunnels', 'start_tunnel', or 'stop_tunnel'")
    print("")
    print("Example: ./tunneler.py -o check_tunnels")
    print("Example: ./tunneler.py -o start_tunnel -e dev")
    sys.exit(1)


if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "o:e:", [ "operation=", "env=" ])
    except getopt.GetoptError:
        usage()

    env = None
    operation = None
    for opt, arg in opts:
        if opt in ("-e", "--env"):
            env = arg
        if opt in ("-o", "--operation"):
            operation = arg

    util = None
    if operation is None:
        pass
    elif operation != "check_tunnels" and operation != "start_tunnel" and operation != "stop_tunnel":
        pass
    elif operation != "check_tunnels":
        if env is None or environments.get(env) is None:
            pass
        else:
            util = TunnelUtil(operation, env)
    else:
        util = TunnelUtil(operation, env)

    if util is not None:
        util.do_work()
    else:
        usage()
