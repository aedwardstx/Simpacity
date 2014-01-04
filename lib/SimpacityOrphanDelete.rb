

#Sometimes, orphan measurements are left behind, need to develop a script to delete them
#Subscription.where([
#  "user_id NOT IN (?) OR channel_id NOT IN (?)",
#    User.pluck("id"),
#      Channel.pluck("id")
#      ]).destroy_all
