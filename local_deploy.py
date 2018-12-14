import os
import sys
import argparse

config_path = os.path.dirname(os.path.abspath(__file__)) + "/etc/kubernetes/"


def kubectl_build_command(config_name):
    return 'cat ' + resolve_config(config_name) + ' | sed "s#{{PWD}}#$PWD#g" | sed "s#{{MINIKUBE_IP}}#$(minikube ip)#g" | kubectl apply -f -'


def resolve_config(config_name):
    filename = config_name if config_name.endswith(".yaml") else config_name + ".yaml"
    return config_path + filename


ingress = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml"
parser = argparse.ArgumentParser(description='Configuration file names.')
parser.add_argument('configs', type=str, nargs='*')
parser.add_argument('--all', action='store_true')
parser.add_argument('--ingress', action='store_true')
args = parser.parse_args()
if args.all:
    args.configs = [filename for filename in os.listdir(config_path) if filename.endswith(".yaml")]

commands = [kubectl_build_command(name) for name in args.configs if os.path.exists(resolve_config(name))]

if args.ingress:
    commands.append(ingress)

map(os.system, commands)
