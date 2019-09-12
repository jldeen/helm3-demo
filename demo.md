# First things first
I'm a huge fan of working smarter not harder so with that in mind, I like to reference variables before I run a series of commands I could easily mess up. (This is also why I'm a huge fan of Helm - cause, you know, variales.
)

## Getting Started
Let's set some variables we will need to run through this tutorial:

```
# for Jenkins Helm Chart Install
namespace=jenkins
helmReleaseName=jenkins
```

### Install
First we need to install helm3. We can do that a few different ways including downloaded the release from here and manually configuring it. 

```
# set helm version
helmVersion=helm-v3.0.0-beta.3-darwin-amd64.tar.gz

# download helm version
wget https://get.helm.sh/$helmVersion
tar xvzf $helmVersion

# mv helm3 binary to local tmp folder
if [[ -e /usr/local/bin/tmp ]] ; then echo "tmp folder already exists" ; else mkdir /usr/local/bin/tmp ; fi
mv darwin-amd64/helm /usr/local/bin/tmp/helm

# TEMPORARY export $HELM_HOME so you don't overwrite Helm2 ~/.helm/
export HELM_HOME=/usr/local/bin/tmp/helm3

# set temp alias
h3=/usr/local/bin/tmp/helm

# add alias to .zshrc or .bashrc
echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.zshrc
# echo "alias h3=/usr/local/bin/tmp/helm" >> ~/.bashrc

# cleanup
rm -rf $helmVersion
rm -rf darwin-amd64
```

Howevever, considering the First Things First Approach (work smarter) I wrote script for you in this repo. Let's just run it: (read it first, maybe?)

`./scripts/setup-helm3.sh`

### Basics
To fully understand just _what_ changed in the latest beta3 release of helm 3, let's try a basic install - an ngnix-ingress controller. 

Note: To ensure we don't confuse ourselves, I changed `helm` to `h3` for helm3 commands (helm2 still works on my machine, and hopefully yours since we left the binary path/home folder preserved).

`h3 upgrade --install nginx-ingress stable/nginx-ingress`

It didn't work. What gives? Remember, the default for Helm3: no repos are added initially - we have to add them. So let's add some familiar repos:

```
helm repo add stable http://storage.googleapis.com/kubernetes-charts
helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
```

Now let's try our nginx-ingress install again:

`h3 upgrade --install nginx-ingress stable/nginx-ingress`

Cool. It works. We can run some basic K8s commands to make sure we can see our Load Balancer IP and pod up and running. 

```
k get pods
k get svc
```

We can optionally setup some CRDS so we can also install a certificate manager (from Jetstack's repo), but it's not _required_ ... up to you.
```
kubectl apply \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
```

Before we try to run a command to deploy another chart, we need to add another repo. This process of adding helm repositories in a distributed sense reflects the direction chart management will move to (distributed model) going forward.

`h3 repo add jetstack https://charts.jetstack.io`

Great, we run `h3 repo list` to see the repos we have added to our helm3 instance.

Now let's install a certificate manager:

`h3 upgrade --install cert-mgr jetstack/cert-manager -n kube-system`

Note: cert-manager needs to be installed into kube-system. Notice how we did not have to ensure Tiller was running or ensure Helm had access to kube-system. Remember, Helm's access resembles the local context's access to the cluster.

Now we have to apply (create) our ClusterIssuer object. You will need to update line 7 of [cluster-issuer.yaml](./cluster-issuer.yaml) with your email address.

`kubectl apply -f cluster-issuer.yaml`

Now let's check to see if we still have Helm2 (don't want to have overwritten anything, right?)

`helm version`

And let's confirm helm3 is still installed:

`h3 version`

Now let's go ahead and see our helm releases. 

`h3 ls`

Uh oh, that's not all of them. We only see 2. Remember, helm releases are now scoped to namespaces. Let's try to `ls` our releases again, but this time with the `--all-namespaces` flag.

`h3 ls --all-namespaces`

#### Plugins
Let's see if I can still install plugins just as I would. I'm going to choose the kubeval plugin for helm since it will helm me validate my charts.

`h3 plugin install https://github.com/instrumenta/helm-kubeval`

If I want to test the above plugin in action, I have to change directories to a path with a helm chart. Let's use our stable/ngnix-ingress helm chart from earlier. I have it locally downloaded (directly from Git so I'm going to change to that directory)

`cd ../charts`

Now I'm going to test the chart with a known bad `--set` variable to see if the plugin still works.

`h3 kubeval stable/nginx-ingress --set controller.replicaCount=twentyfive`

Sure enough, amongh other warnings (a bunch of files contain empty YAML documents), I also see this error:

```sh
The file nginx-ingress/templates/controller-deployment.yaml contains an invalid Deployment
---> spec.replicas: Invalid type. Expected: [integer,null], given: string
```
That's a good thing - this means our plugin worked as expected! 

Now let's take a look at the new XDG model for config paths:

```
h3 --help (see table)
ls $HOME/.cache/helm (linux)
ls $HOME/Library/Caches/helm/ (macOS)
```

Now let's deploy something fun - how about a Jenkins build server. I have a pre-provided [values.yaml](./jenkins-values-demo.yaml). You will just need to update this block of code (lines 47-51) to your environment and DNS:
```
    hostName: helmsummit.h3.az.jessicadeen.com
    tls:
      - secretName: helmsummit.h3.az.jessicadeen.com
        hosts:
          - helmsummit.h3.az.jessicadeen.com
```

Once you confirm the values file is as you want it, let's install the jenkins chart!

`h3 upgrade jenkins --install --namespace $namespace -f ./jenkins-values-demo.yaml stable/jenkins`

While the Jenkins build server is installing, let's try one more chart repo add for fun. Let's add my public repo (hosted in Azure Blob Storage, btw):

`h3 repo add jdcharts https://jdk8s.blob.core.windows.net/helm/`

And, without further ado, let's bring back crochunter.

`h3 upgrade crochunter --install --namespace default --set ingress.hostname=crochunter.h3.az.jessicadeen.com,image=jldeen/croc-hunter,imageTag=0.3.1 jdcharts/croc-hunter`

Note: You will have to update the `ingress.hostname` with a hostname that is specific to your domain and your ingress/DNS.

Now let's check on our Jenkins deployment:

`kubectl get pods -n $namespace`

Once jenkins is deployed (using the same chart we would use with Helm2), we can run our usual `printf` command to get our admin password (since we didn't define one in our values.yaml).
 
`printf $(kubectl get secret --namespace default jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo`

## Bonus: Setup your own crochunter with your new Jenkins

I created a special croc-hunter [branch](https://github.com/jldeen/croc-hunter/tree/helmsummit) for everyone at Helm Summit and everyone who is learning the new differences betweeen Helm 2 and Helm 3. This branch has a special Jenkinsfile that will make it easy to setup our own pipeline to build our own CI instance of this wonderful and graphic intensive web app. Guess what - the Jenkinsfile runs a container based pipeline and uses Helm 3 too for linting and packaging! Nice!

`git clone https://github.com/jldeen/croc-hunter`

First, let's take a look at the croc hunter chart - it's one of the oldest charts around. Let's lint our chart with both helm 2 and helm 3 (on the master branch) to see any differences:

```
helm lint
h3 lint
```

Notice the difference? We not get an error in Helm 3 because we didn't specify `apiVersion:` in our chart.yaml, which is now required. You'll notice the chart in our `helmsummit` branch includes the requried `apiVersion:1`

### TO DO: add in rest of Jenkins Bonus Demo

#### Helpful tools

[kubens and kubectx](https://github.com/ahmetb/kubectx) or `brew install kubectx`
