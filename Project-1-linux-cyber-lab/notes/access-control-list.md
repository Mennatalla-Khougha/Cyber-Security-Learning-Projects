## ACL: Access Control List
- Fine-grained permission for users & groups
```
sudo apt install -y acl
```
- for users
```
sudo setfacl -m u:<user>:<permissions> <file/dir-name>
```

```
getfacl <file/dir-name>
```
- for groups
```
sudo setfacl -m g:<group>:<permissions> <file/dir-name>
```

```
getfacl <file/dir-name>
```

