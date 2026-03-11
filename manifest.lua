--- @version 1.2.3
--- @diagnostic disable: missing-return
--- @diagnostic disable: duplicate-set-field
syscall={}

--- @alias userinfo {username:string,homedir:string,shell:string,uid:number,gid:number}

--- Sets home directory of User with corresponding uid to homedir
--- @param uid integer
--- @param homedir string
--- @return true|nil, nil|string
syscall.sethomedir=function(uid, homedir) end

--- Reads amount from fd and returns content or nil
--- @param fd integer
--- @param amount? integer
--- @return string|nil
syscall.read=function(fd, amount) end

--- Gets information of task with id of pid
---@param pid integer
---@return table|nil
syscall.getTask=function(pid) end

--- Connects a client socket to a server address
---@param fd integer
---@param address string
---@return boolean, string|nil
syscall.connect=function(fd, address) end

--- Get current working directory
--- @return string
syscall.getcwd=function() end

--- Detach loop device (must be unmounted first)
--- @param id string
--- @return boolean, string|nil
syscall.lodetach=function(id) end

--- Stops task with id of pid
--- @param pid integer
--- @return boolean, string|nil
syscall.stop=function(pid) return true end

--- Receive bytes from socket (blocking poll, returns "" if no data)
--- @param fd integer
--- @param amount integer
--- @return string
syscall.recv=function(fd, amount) end

--- Write data to file descriptor
--- @param fd integer
--- @param data string
--- @return boolean, string|nil
syscall.write=function(fd, data) end

--- Get parent process ID
--- @return integer
syscall.getppid=function() end

--- Get file information (metadata)
--- @param path string
--- @return table|nil
syscall.lstat=function(path) end

--- Open a file with mode ("r", "w", etc.)
--- @param path string
--- @param mode string
--- @return integer|nil, string|nil
syscall.open=function(path, mode) end

--- Seek in a file descriptor
--- @param fd integer
--- @param offset integer
--- @param whence integer
--- @return integer|nil
syscall.lseek=function(fd, offset, whence) end

--- Set system hostname
--- @param hostname string
--- @return boolean
syscall.setHostname=function(hostname) end

--- Change root directory
--- @param path string
--- @return boolean, string|nil
syscall.chroot=function(path) end

--- Duplicate file descriptor
--- @param src integer
--- @param dst integer
--- @return integer|nil, string|nil
syscall.dup2=function(src, dst) end

--- Get current process ID
--- @return integer
syscall.getpid=function() end

--- Change ownership of a file descriptor
--- @param fd integer
--- @param uid integer
--- @param gid integer
--- @return boolean, string|nil
syscall.fchown=function(fd, uid, gid) end

--- Close a file descriptor
--- @param fd integer
--- @return boolean, string|nil
syscall.close=function(fd) end

--- Unmount a target
--- @param target string
--- @return boolean, string|nil
syscall.umount=function(target) end

--- Get all task IDs
--- @return integer[]
syscall.getTasks=function() end

--- Dump all syscalls for debugging
--- @return table
syscall.sysdump=function() end

--- Change permissions of a file descriptor
--- @param fd integer
--- @param perms integer
--- @return boolean, string|nil
syscall.fchmod=function(fd, perms) end

--- Get system hostname
--- @return string
syscall.getHostname=function() end

--- Listen for incoming connections
--- @param fd integer
--- @param backlog integer
--- @return boolean, string|nil
syscall.listen=function(fd, backlog) end

--- Duplicate a file descriptor
--- @param fd integer
--- @return integer|nil
syscall.dup=function(fd) end

--- Read GPIO pin
--- @param pin integer
--- @return number|nil
syscall.gpio_read=function(pin) end

--- Get SUID bit from fd
--- @param fd integer
--- @return boolean
syscall.fget_suid=function(fd) end

--- Write GPIO pin
--- @param pin integer
--- @param data number
--- @return boolean
syscall.gpio_write=function(pin, data) end

--- Set password for user
--- @param uid integer
--- @param newPassword string
--- @return boolean, string|nil
syscall.setpassword=function(uid, newPassword) end

--- Set environment variable
--- @param key string
--- @param value any
--- @return boolean
syscall.setEnviron=function(key, value) end

--- Setup a loop device with filePath
--- @param filePath string
--- @param forceImage boolean
--- @return string|nil, string|nil
syscall.losetup=function(filePath, forceImage) end

--- Reboot the system
syscall.reboot=function() end

--- Get current user ID
--- @return integer
syscall.getuid=function() end

--- Send signal to task
--- @param pid integer
--- @param sigid integer|string
--- @return boolean, string|nil
syscall.sigsend=function(pid, sigid) end

--- Sleep current task for time seconds
--- @param time number
syscall.sleep=function(time) end

--- Exit current task
--- @param code integer|nil
syscall.exit=function(code) end

--- Get environment variable
--- @param key string
--- @return any
syscall.getEnviron=function(key) end

--- Continue a stopped task
--- @param pid integer
--- @return boolean, string|nil
syscall.continue=function(pid) end

--- Create a socket
--- @param domain integer
--- @param socktype integer
--- @return integer|nil
syscall.socket=function(domain, socktype) end

--- Log a message
--- @param text string
--- @param tag string
--- @param color integer
syscall.log=function(text, tag, color) end

--- Write an image to disk
--- @param imgStr string
--- @param destPath string
--- @return boolean, string|nil
syscall.loimgwrite=function(imgStr, destPath) end

--- Check if file exists
--- @param path string
--- @return boolean
syscall.exists=function(path) end

--- Set user ID of current task
--- @param uid integer
--- @return boolean, string|nil
syscall.setuid=function(uid) end

--- Replace current task with executable
--- @param path string
--- @param args? table
--- @param envars? table
syscall.exec=function(path, args, envars) end

--- Spawn a new task from executable
--- @param path string
--- @param name? string
--- @param envars? table
--- @param args? table
--- @param tgid? integer
--- @return integer
syscall.execspawn=function(path, name, envars, args, tgid) end

--- Create image from file
--- @param srcPath string
--- @return string|nil
syscall.loimgcreate=function(srcPath) end

--- Get system time in ms
--- @return number
syscall.time=function() end

--- Create a new user
--- @param username string
--- @param password string
--- @param gid integer
--- @param homedir string
--- @param shell string
--- @return integer|nil
syscall.newuser=function(username, password, gid, homedir, shell) end

--- Spawn a new task from function
--- @param func function
--- @param name? string
--- @param envars? table
--- @param args? table
--- @param tgid? integer
--- @return integer
syscall.spawn=function(func, name, envars, args, tgid) end

--- Collect exit code of a dead child task
--- @param pid integer
--- @return boolean, integer|string
syscall.collect=function(pid) end

--- Set shell of user
--- @param uid integer
--- @param shell string
--- @return boolean
syscall.setshell=function(uid, shell) end

--- Device control
--- @param fd integer
--- @param funcname string
--- @param ... any
--- @return any
syscall.devctl=function(fd, funcname, ...) end

--- List all users
--- @return table
syscall.listusers=function() end

--- Unlock a user account
--- @param uid integer
--- @return boolean
syscall.unlockuser=function(uid) end

--- Mount a disk or loop device
--- @param target string
--- @param diskOrId string
--- @return boolean, string|nil
syscall.mount=function(target, diskOrId) end

--- Accept a client connection on a socket
--- @param fd integer
--- @return integer|nil
syscall.accept=function(fd) end

--- List loop devices
--- @return table
syscall.lolist=function() end

--- Read a symbolic link
--- @param path string
--- @return string|nil
syscall.readlink=function(path) end

--- Delete a user
--- @param uid integer
--- @return boolean
syscall.deleteuser=function(uid) end

--- Remove a file
--- @param path string
--- @return boolean, string|nil
syscall.remove=function(path) end

--- Get type of a path (file, dir, link)
--- @param path string
--- @return string|nil
syscall.type=function(path) end

--- Elevate to root with password (Disabled due to VULN)
--- @param targetUsername string
--- @param password string
--- @return boolean
syscall.elevate=function(targetUsername, password) end

--- Make a directory
--- @param path string
--- @return boolean, string|nil
syscall.mkdir=function(path) end

--- Get UID by username
--- @param username string
--- @return integer|nil
syscall.getuidbyname=function(username) end

--- Get current user name
--- @return string
syscall.whoami=function() end

--- Send file content
--- @param src string
--- @param dest string
--- @param amount integer
--- @return boolean, string|nil
syscall.sendfile=function(src, dest, amount) end

--- Change username of user
--- @param uid integer
--- @param newUsername string
--- @return boolean
syscall.setusername=function(uid, newUsername) end

--- Get effective UID
--- @return integer
syscall.geteuid=function() end

--- Login as user
--- @param uid integer
--- @param password string
--- @return boolean
syscall.login=function(uid, password) end

--- Get system hostname
--- @return string
syscall.getHost=function() end

--- Get system uptime in ms
--- @return number
syscall.getUptime=function() end

--- HTTP GET request
--- @param url string
--- @param headers table|nil
--- @return string|nil
syscall.httpget=function(url, headers) end

--- Get file metadata
--- @param path string
--- @return table|nil
syscall.stat=function(path) end

--- Create symbolic link
--- @param target string
--- @param linkPath string
--- @return boolean, string|nil
syscall.symlink=function(target, linkPath) end

--- Read from fd at offset
--- @param fd integer
--- @param count integer
--- @param offset integer
--- @return string|nil
syscall.pread=function(fd, count, offset) end

--- Change current working directory
--- @param path string
--- @return boolean, string|nil
syscall.chdir=function(path) end

--- Get system architecture
--- @return string
syscall.arch=function() end

--- Write to fd at offset
--- @param fd integer
--- @param data string
--- @param offset integer
--- @return boolean, string|nil
syscall.pwrite=function(fd, data, offset) end

--- Shutdown socket
--- @param fd integer
--- @return boolean, string|nil
syscall.sockshutdown=function(fd) end

--- Resolve hostname to IP
--- @param hostname string
--- @return string|nil
syscall.resolve=function(hostname) end

--- Send data over socket
--- @param fd integer
--- @param data string
--- @return boolean, string|nil
syscall.send=function(fd, data) end

--- Get file descriptor info
--- @param fd integer
--- @return table|nil
syscall.fstat=function(fd) end

--- Change ownership of path
--- @param path string
--- @param uid integer
--- @param gid integer
--- @return boolean, string|nil
syscall.chown=function(path, uid, gid) end

--- Flush file descriptor
--- @param fd integer
--- @return boolean, string|nil
syscall.fsync=function(fd) end

--- Lock user account
--- @param uid integer
--- @return boolean
syscall.lockuser=function(uid) end

--- Get username by UID
--- @param uid integer
--- @return string|nil
syscall.getUsername=function(uid) end

--- Get socket name
--- @param fd integer
--- @return string|nil
syscall.getsockname=function(fd) end

--- Bind socket to address
--- @param fd integer
--- @param address string
--- @return boolean, string|nil
syscall.bind=function(fd, address) end

--- Kill a task
--- @param pid integer
--- @return boolean, string|nil
syscall.kill=function(pid) end

--- Set GID for user
--- @param uid integer
--- @param gid integer
--- @return boolean
syscall.setgid=function(uid, gid) end

--- Get peer name of socket
--- @param fd integer
--- @return string|nil
syscall.getpeername=function(fd) end

--- Set signal handler
--- @param handler function
syscall.sigcatch=function(handler) end

--- Shutdown the system
syscall.shutdown=function() end

--- Check file access mode
--- @param path string
--- @param mode string
--- @return boolean
syscall.access=function(path, mode) end

--- Ignore current signal
syscall.sigignore=function() end

--- Get user information
--- @param uid integer
--- @return userinfo|nil
syscall.getpasswd=function(uid) end

--- Get OS version
--- @return string
syscall.version=function() end

--- Change file permissions
--- @param path string
--- @param perms integer
--- @return boolean
syscall.chmod=function(path, perms) end

--- List directory contents
--- @param path string
--- @return table
syscall.listdir=function(path) end


----------------------------------------------
--- STDLib manifest
----------------------------------------------

--- Gets the index of value or -1
--- @param tabl table
--- @param value string|integer
--- @return integer
table.indexOf=function(tabl, value) end

-- Returns true if tabl has key else false
--- @param tabl table
--- @param query string
--- @return boolean
table.hasKey=function(tabl, query) end

--- Returns true if tabl has value else false
--- @param tabl table
--- @param query any
--- @return boolean
table.hasVal=function(tabl, query) end

--- Creates a deepcopy of tabl
--- @param tabl table
--- @return table
table.deepcopy=function(tabl) end

--- Returns the keys of tabl
--- @param tabl table
--- @return table
table.keys=function(tabl) end

--- Returns the values of tabl
--- @param tabl table
--- @return table
table.values=function(tabl) end

--- Returns a serialized version of tabl
--- @param tabl table
--- @return string
table.serialize=function(tabl) end

--- Returns a merged table with a and b
--- @param ... table
--- @return table
table.merge=function(...) end

--- Gets prefix of string with suffix
--- @param str string
--- @param suffix string
--- @return string
string.getPrefix=function(str, suffix) end

--- Gets suffix of string with prefix
--- @param str string
--- @param prefix string
--- @return string
string.getSuffix=function(str, prefix) end

--- Returns if sting has prefix
--- @param str string
--- @param prefix string
--- @return boolean
string.hasPrefix=function(str, prefix) end

--- Returns if sting has suffix
--- @param str string
--- @param suffix string
--- @return boolean
string.hasSuffix=function(str, suffix) end

--- Joins all args
--- @param str string
--- @param ... string
--- @return string
string.join=function(str, ...) end

--- Joins all strings with delim
--- @param delim string
--- @param ... string
--- @return string
string.delim=function(delim, ...) end

--- Splits a string by delim
--- @param str string
--- @param delim string
--- @return table
string.split=function(str, delim) end

--- Replaces all instances of target with repl
--- @param str string
--- @param target string
--- @param repl string
--- @return string
string.replace=function(str, target, repl) end

--- Converts a number to hex
--- @param num integer
--- @return string
toHex=function(num) end

--- Returns if obj is equal to all in ...
--- @param obj any
--- @param ... any
--- @return boolean
isEqualToAll=function(obj, ...) end

--- Returns if obj is equal to any in ...
--- @param obj any
--- @param ... any
--- @return boolean
isEqualToAny=function(obj, ...) end

--- Prints text to stdout
--- @param ... any
print=function(...) end

--- Prints text to stdout but with no trailing newline
--- @param ... any
printInline=function(...) end

--- Prints text to stdout with format
--- @param fmt string
--- @param ... any
printf=function(fmt, ...) end