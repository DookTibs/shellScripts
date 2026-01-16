import os, re, sys

# little python script that parses the tee'd output of pianobar to retrieve station nums/names

if len(sys.argv) < 3:
    os._exit(1)
else:
    op = sys.argv[1]
    deets = sys.argv[2]

# https://stackoverflow.com/questions/2301789/how-to-read-a-file-in-reverse-order
def reverse_readline(filename, buf_size=8192):
    """A generator that returns the lines of a file in reverse order"""
    with open(filename, 'rb') as fh:
        segment = None
        offset = 0
        fh.seek(0, os.SEEK_END)
        file_size = remaining_size = fh.tell()
        while remaining_size > 0:
            offset = min(file_size, offset + buf_size)
            fh.seek(file_size - offset)
            buffer = fh.read(min(remaining_size, buf_size))
            # remove file's last "\n" if it exists, only for the first buffer
            if remaining_size == file_size and buffer[-1] == ord('\n'):
                buffer = buffer[:-1]
            remaining_size -= buf_size
            lines = buffer.split('\n'.encode())
            # append last chunk's segment to this chunk's last line
            if segment is not None:
                lines[-1] += segment
            segment = lines[0]
            lines = lines[1:]
            # yield lines in this chunk except the segment
            for line in reversed(lines):
                # only decode on a parsed line, to avoid utf-8 decode error
                yield line.decode()
        # Don't yield None if the file was empty
        if segment is not None:
            yield segment.decode()

stations = []
station_title_pattern = r" *([0-9]*)\) *[qQ] (.*)"
now_playing_song_pattern = r'\|> *(.*) by "(.*)" on (.*)'
i = 0
showing_stations = False
song_data = None
for line_from_file in reverse_readline("/Users/38593/development/shellScripts/pianoBarLog.txt"):
    # print(f"CHECK '{line_from_file}'")
    if song_data is None:
        song_match = re.search(now_playing_song_pattern, line_from_file)
        if song_match:
            song_data = (song_match.group(1)[1:-1], song_match.group(2), song_match.group(3)[1:-1])

    m = re.search(station_title_pattern, line_from_file)
    if m:
        if not showing_stations:
            showing_stations = True
        # print(f"[{i}] [{line_from_file}]")
        station_num = int(m.group(1))
        station_title = m.group(2).strip()
        stations.append( { "num": station_num, "title": station_title } )
        # print(f"\t[{station_num}]: [{station_title}]")
    else:
        if showing_stations and stations[-1]["num"] == 1:
            stations.reverse()
            break
    i += 1
    if i >= 100:
        #break
        pass

if op == "stationnum":
    """
    for s in stations:
        print(f"station [{s['num']}]: [{s['title']}]")
    print("-----")
    """
    matching_stations = [s for s in stations if deets in s['title']]
    exact_matches = [s for s in stations if deets == s['title']]

    if len(exact_matches) == 1:
        print(exact_matches[0]['num'], flush=True)
    else:
        if len(matching_stations) == 1:
            print(matching_stations[0]['num'], flush=True)
        else:
            if len(matching_stations) == 0:
                print(f"no station matching given name")
            else:
                print(f"ambiguous request: {matching_stations}")
            os._exit(1)
elif op == "currsong":
    if song_data is not None:
        print(f"NOW PLAYING: title='{song_data[0]}'; artist='{song_data[1]}', album='{song_data[2]}'")
    else:
        print(f"could not detect song data...")
else:
    print(f"invalid args '{sys.argv}'")
"""
for s in stations:
    print(f"station [{s['num']}]: [{s['title']}]")

if song_data is not None:
    print(f"NOW PLAYING: title='{song_data[0]}'; artist='{song_data[1]}', album='{song_data[2]}'")
else:
    print(f"could not detect song data...")
"""
