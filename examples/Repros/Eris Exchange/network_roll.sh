echo $(date -u) "Network going down"
sudo ip link set eth0 down
echo $(date -u) "Taking a small nap"
sudo sleep 120
echo $(date -u) "Network coming back online"
sudo ip link set eth0 up