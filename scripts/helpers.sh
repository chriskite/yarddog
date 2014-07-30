case $1 in
start)
    ruby -r ~/git/yarddog/server/app/models/ec2.rb -e 'EC2.create'
    ;;
stop)
    ruby -r ~/git/yarddog/server/app/models/ec2.rb -e 'EC2.all.map(&:destroy)'
    ;;
ssh)
    ssh -i ~/company/yarddog.pem -o 'StrictHostKeyChecking no' ubuntu@$(ruby -r ~/git/yarddog/server/app/models/ec2.rb -e 'puts EC2.all.first.private_ip_address')
esac
