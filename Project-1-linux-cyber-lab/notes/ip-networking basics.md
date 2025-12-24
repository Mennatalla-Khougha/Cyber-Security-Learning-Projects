### Network Interfaces to get the server ip 
```
ip a
```

### Routing table
```
ip route
```

### Connectivity Tests
```
ping -c 3 8.8.8.8
ping -c 3 google.com
```

### List Listening Ports
```
ss -tulnp
```

### More network info 
show the ip & some more info
```
ifconfig
```

show Active Internet connections (only servers) for all process info use sudo
```
netstat -tulnp
```