# To force HN to be the manatee primary (joshw recommends this)

if HN is async:
  * stop/reboot sync (it will become async, HN become sync)
  * when HN becomes sync, move on

if/when HN is sync:
  * stop/reboot primary (it will come back deposed, HN becomes primary)
  * when deposed comes back: `manatee-adm rebuild` it
  * when everything's back, move on

if HN is primary:
  * great! Try not to mess it up.


# Reboot Order

If you've done the above you can always do the following to reboot these CNs
safely without needing to rebuild. To do so:

 1. reboot the CN with the async
 2. wait for the cluster to stablize (and async to catch back up)
 3. reboot the CN with the sync
 4. wait for the cluster to stablize (and async -- formerly sync -- to catch back up)
 5. if HN reboot is not required, you're done! Safely reboot any other non-manatee CNs now.
 6. freeze the manatee cluster by logging into manatee on HN and `manatee-adm freeze -r reboot`
 7. reboot the HN
 8. when HN is back up, login to manatee zone and `manatee-adm unfreeze`


