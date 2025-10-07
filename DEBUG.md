# Debugging Guide

## Check VNC Connection

When the build runs, Packer will output a VNC connection string like:
```
vnc://127.0.0.1:5972
```

**Connect to it to see what's actually happening during boot!**

Use a VNC client (TigerVNC, RealVNC, TightVNC, etc.) to connect and watch the installation.

## Common Issues

### 1. Runner Network Issues
If the autoinstall starts but hangs during package installation:
- The runner might not have internet access
- Check: `curl -I http://archive.ubuntu.com/ubuntu/`

### 2. Boot Command Not Working
If you see the GRUB menu instead of autoinstall starting:
- The boot command timing might be off
- VNC will show you what's happening

### 3. HTTP Server Not Reachable
Check in the Packer logs for:
```
Starting HTTP server on port XXXX
```

The VM should be able to reach `http://<runner-ip>:XXXX/user-data`

## Test Locally First

Before running in CI, test locally:
```bash
cd c:\Users\Admin\Desktop\image-builder
packer init ubuntu-qcow2.pkr.hcl
packer validate ubuntu-qcow2.pkr.hcl
PACKER_LOG=1 packer build ubuntu-qcow2.pkr.hcl
```

## Quick Test Without Autoinstall

To verify the runner can boot VMs at all:
1. Set `headless = false`
2. Comment out the `boot_command`
3. Run the build
4. Connect via VNC and manually install to verify virtualization works

