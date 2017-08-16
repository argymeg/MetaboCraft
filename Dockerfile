FROM pimpcraft-base

COPY install_r_packages.sh /home/pimpcraft/pimpcraft/install_r_packages.sh
RUN /home/pimpcraft/pimpcraft/install_r_packages.sh
COPY . /home/pimpcraft/pimpcraft
RUN chown -R pimpcraft:pimpcraft /home/pimpcraft
USER pimpcraft
WORKDIR /home/pimpcraft/pimpcraft
RUN ./install.sh