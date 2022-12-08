from http.server import HTTPServer, BaseHTTPRequestHandler
import argparse
import subprocess
from urllib import parse
import os
import requests
import json
import logging

APP_VERSION = '0.2'
# logger config
logger = logging.getLogger()
logging.basicConfig(level=logging.INFO,
                    format='%(message)s')


class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()

    def _html(self, message):
        return message.enapp("utf8")

    def do_GET(self):
        query = requests.utils.urlparse(self.path).query
        self.send_response(200)
        logger.error(f"self.path: {self.path}")
        if '/jmeter' in self.path:
            params = dict(x.split('=') for x in query.split('&'))
            if 'project' not in params:
                out = "{\"error\": \"project is required.\"}"
            else:
                out = self.get_run(params)
            self.end_headers()
            self.wfile.write(bytes(out, 'utf-8'))
            return
        elif '/broadcast' in self.path:
            params = dict(x.split('=') for x in query.split('&'))
            if 'project' not in params:
                out = "{\"error\": \"project is required.\"}"
            else:
                out = self.get_broadcast(params)
            self.end_headers()
            self.wfile.write(bytes(out, 'utf-8'))
            return
        elif '/filebeat' in self.path:
            params = dict(x.split('=') for x in query.split('&'))
            if 'cmd' not in params:
                out = "{\"error\": \"cmd is required.\"}"
            elif params['cmd'] == 'import':
                if params['project'] == 'debug':
                    ri_cmd = "bash /Volumes/workspace/tz/tz-jmeter-k8s/jmeter/import.sh"
                else:
                    ri_cmd = "bash /home/jmeter/import.sh"
                out = self.run_shell(ri_cmd)
            self.end_headers()
            self.wfile.write(bytes(out, 'utf-8'))
            return
        elif self.path == '/health':
            out = "{\"version\": \"" + APP_VERSION + "\"}"
            self.end_headers()
            self.wfile.write(bytes(out, 'utf-8'))
            return

        root = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'static')
        logger.info(self.path)
        if self.path == '/':
            filename = root + '/index.html'
        else:
            filename = root + self.path
        self.send_response(200)
        if filename[-4:] == '.css':
            self.send_header('Content-type', 'text/css')
        elif filename[-5:] == '.json':
            self.send_header('Content-type', 'application/javascript')
        elif filename[-3:] == '.js':
            self.send_header('Content-type', 'application/javascript')
        elif filename[-4:] == '.ico':
            self.send_header('Content-type', 'image/x-icon')
        else:
            self.send_header('Content-type', 'text/html')
        self.end_headers()
        with open(filename, 'rb') as fh:
            html = fh.read()
            self.wfile.write(html)

    def get_run(self, params=[]):
        if params['project'] == '':
            return 'project is required.'
        # self.run_shell("kill -9 `ps -ef | grep run.sh | awk '{print $2}' | head -n 1`")
        if params['project'] == 'debug':
            # /bin/bash /Volumes/workspace/tz/tz-jmeter-k8s/jmeter/run.sh ${protocol} ${serverAddr} ${serverPort} ${timeSec} ${loopCnt} ${userNumber}
            ri_cmd = "/bin/bash /Volumes/workspace/tz/tz-jmeter-k8s/jmeter/run.sh " + \
                     params['project'] + " " + params['protocol'] + " " + params['serverAddr'] + " " + params['serverPort'] + " " + \
                     params['timeSec'] + " " + params['loopCnt'] + " " + params['userNumber'] + " " + params['jmx']
        else:
            ri_cmd = "/bin/bash /home/jmeter/run.sh " + \
                     params['project'] + " " + params['protocol'] + " " + params['serverAddr'] + " " + params['serverPort'] + " " + \
                     params['timeSec'] + " " + params['loopCnt'] + " " + params['userNumber'] + " " + params['jmx']
        return self.run_shell(ri_cmd)

    def get_broadcast(self, params=[]):
        if params['project'] == '':
            return 'project is required.'
        if params['project'] == 'debug':
            ri_cmd = "/bin/bash /Volumes/workspace/tz/tz-jmeter-k8s/jmeter/broadcast.sh " + \
                     params['project'] + " " + params['protocol'] + " " + params['serverAddr'] + " " + params['serverPort'] + " " + \
                     params['timeSec'] + " " + params['loopCnt'] + " " + params['userNumber'] + " " + params['jmx']
        else:
            ri_cmd = "/bin/bash /home/jmeter/broadcast.sh " + \
                     params['project'] + " " + params['protocol'] + " " + params['serverAddr'] + " " + params['serverPort'] + " " + \
                     params['timeSec'] + " " + params['loopCnt'] + " " + params['userNumber'] + " " + params['jmx']
        return self.run_shell(ri_cmd)

    def run_shell(self, ri_cmd):
        logger.info(f"ri_cmd: {ri_cmd}")
        process = subprocess.Popen(
            ri_cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True)
        RArry = []
        for out1 in iter(process.stdout.readline, b''):
            if out1 == '':
                break
            out1 = out1.replace('\n', '')
            RArry.append(out1)
            if 'end of run' in out1:
                break
        return "{\"result\": " + json.dumps(RArry) + "}"


def run(server_class=HTTPServer, handler_class=S, addr="localhost", port=8000):
    server_address = (addr, port)
    httpd = server_class(server_address, handler_class)
    logger.info(f"Starting httpd server on {addr}:{port}")
    httpd.serve_forever()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run a simple HTTP server")
    parser.add_argument(
        "-l",
        "--listen",
        default="0.0.0.0",  # localhost
        help="Specify the IP address on which the server listens",
    )
    parser.add_argument(
        "-p",
        "--port",
        type=int,
        default=8000,
        help="Specify the port on which the server listens",
    )
    args = parser.parse_args()
    run(addr=args.listen, port=args.port)
