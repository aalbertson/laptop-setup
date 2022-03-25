# Quick setup for a macos (OSX) laptop with basic tools
The scripts and playbooks contained here are designed to give you an easy to run quick laptop setup tool for macOS. This helps reduce the startup time of an engineer that might be just starting OR someone that needed to wipe their machine.

The intention of this is that you'll take this example, and do one of the two following things:
1. Make it your own, ansible is easy, so please customize this example to suit your needs
2. For any changes you make that would be nice as defaults for others, please back port them into this repo

## Setup
Elementary my dear watson, simply:

```
$ ./setup.sh
```

From your terminal. This will take care of the all the prereqs you'll need in order to get this working

Note: You MUST run the above step before anything else. It WILL fail when it asks you to do the ansible work because it had to setup the prereqs.


That's all folks! Hit me up anywhere you can find me if you have any questions.
