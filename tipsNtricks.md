## NFS
disable NFS in labs before the first boot
```vagrant config nfs_shares off```

forward port 80 to port 8080
```sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 8080```
