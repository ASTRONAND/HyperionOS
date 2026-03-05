syscall={}

--- Sets home directory of User with corosponding uid to homedir
--- @param uid integer
--- @param homedir string
--- @return true|nil, nil|string
syscall.sethomedir=function(uid, homedir) end

--- Reads amount from fd and returns content or nil
--- @param fd integer
--- @param amount integer
--- @return string|nil
syscall.read=function(fd, amount) end

--- Gets information of task with id of pid
---@param pid integer
---@return table|nil
syscall.getTask=function(pid) end

--- client: connect to server address
---@param fd integer
---@param address string
---@return nil
syscall.connect=function(fd, address) end

--- Get current working directory
--- @return string
syscall.getcwd=function() return "string" end

--- detach loop device (must be unmounted first)
--- @param id string
--- @return nil
syscall.lodetach=function(id) end

--- Stops task with id of pid
--- @param pid integer
--- @return boolean, string|nil
syscall.stop=function(pid) return true end

--- Receive bytes from socket (blocking poll, returns "" on nothing)
--- @param fd integer
--- @param amount integer
--- @return string
syscall.recv=function(fd, amount) return "string" end

syscall.write=function(fd, data) end
syscall.getppid=function() end
syscall.lstat=function(path) end
syscall.open=function(path, mode) end
syscall.lseek=function(fd, offset, whence) end
syscall.setHostname=function(hostname) end
syscall.chroot=function(path) end
syscall.dup2=function(src, dst) end
syscall.getpid=function() end
syscall.fchown=function(fd, uid, gid) end
syscall.close=function(fd) end
syscall.umount=function(target) end
syscall.getTasks=function() end
syscall.sysdump=function() end
syscall.fchmod=function(fd, perms) end
syscall.getHostname=function() end
syscall.listen=function(fd, backlog) end
syscall.dup=function(fd) end
syscall.gpio_read=function(pin) end
syscall.fget_suid=function(fd) end
syscall.gpio_write=function(pin, data) end
syscall.setpassword=function(uid, newPassword) end
syscall.setEnviron=function(key, value) end
syscall.losetup=function(filePath, forceImage) end
syscall.reboot=function() end
syscall.getuid=function() end
syscall.sigsend=function(pid, sigid) end
syscall.sleep=function(time) end
syscall.exit=function(code) end
syscall.getEnviron=function(key) end
syscall.continue=function(pid) end
syscall.socket=function(domain, socktype) end
syscall.log=function(text, tag, color) end
syscall.loimgwrite=function(imgStr, destPath) end
syscall.exists=function(path) end
syscall.setuid=function(uid) end
syscall.exec=function(path, args, envars) end
syscall.execspawn=function(path, name, envars, args, tgid) end
syscall.loimgcreate=function(srcPath) end
syscall.time=function() end
syscall.newuser=function(username, password, gid, homedir, shell) end
syscall.spawn=function(func, name, envars, args, tgid) end
syscall.collect=function(pid) end
syscall.setshell=function(uid, shell) end
syscall.devctl=function(fd, funcname, ...) end
syscall.listusers=function() end
syscall.unlockuser=function(uid) end
syscall.mount=function(target, diskOrId) end
syscall.accept=function(fd) end
syscall.lolist=function() end
syscall.readlink=function(path) end
syscall.deleteuser=function(uid) end
syscall.remove=function(path) end
syscall.type=function(path) end
syscall.elevate=function(targetUsername, password) end
syscall.mkdir=function(path) end
syscall.getuidbyname=function(username) end
syscall.whoami=function() end
syscall.sendfile=function(src, dest, amount) end
syscall.setusername=function(uid, newUsername) end
syscall.geteuid=function() end
syscall.login=function(username, password) end
syscall.getHost=function() end
syscall.getUptime=function() end
syscall.httpget=function(url, headers) end
syscall.stat=function(path) end
syscall.symlink=function(target, linkPath) end
syscall.pread=function(fd, count, offset) end
syscall.chdir=function(path) end
syscall.arch=function() end
syscall.pwrite=function(fd, data, offset) end
syscall.sockshutdown=function(fd) end
syscall.resolve=function(hostname) end
syscall.send=function(fd, data) end
syscall.fstat=function(fd) end
syscall.chown=function(path, uid, gid) end
syscall.fsync=function(fd) end
syscall.lockuser=function(uid) end
syscall.getUsername=function(uid) end
syscall.getsockname=function(fd) end
syscall.bind=function(fd, address) end
syscall.kill=function(pid) end
syscall.setgid=function(uid, gid) end
syscall.getpeername=function(fd) end
syscall.sigcatch=function(handler) end
syscall.shutdown=function() end
syscall.access=function(path, mode) end
syscall.sigignore=function() end
syscall.getpasswd=function(uid) end
syscall.version=function() end
syscall.chmod=function(path, perms) end
syscall.listdir=function(path) end