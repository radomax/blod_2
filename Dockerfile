FROM phpmyadmin/phpmyadmin

ENV PMA_HOST=containers-us-west-xxx.railway.app
ENV PMA_PORT=your_tcp_proxy_port
ENV PMA_USER=root
ENV PMA_PASSWORD=BLJAiPrTYrgHfMPmKqTlgxgrFeXolRBa

EXPOSE 80