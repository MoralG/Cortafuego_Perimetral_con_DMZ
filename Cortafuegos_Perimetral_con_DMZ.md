# Cortafuegos perimetral con DMZ

### Esquema de red

----------------------------------------------------------------------------------

#### Vamos a utilizar tres máquinas en openstack, que vamos a crear con la receta heat: escenario3.yaml. La receta heat ha deshabilitado el cortafuego que nos ofrece openstack (todos los puertos de todos los protocolos están abiertos). Una máquina (que tiene asignada una IP flotante) hará de cortafuegos, otra será una máquina de la red interna 192.168.100.0/24 y la tercera será un servidor en la DMZ donde iremos instalando distintos servicios y estará en la red 192.168.200.0/24.

### Ejercicios

> Para listar las reglas de IPTABLES:
~~~
sudo iptables -L -nv --line-numbers
~~~
> Para eliminar las reglas de IPTABLES:
~~~
sudo iptables -D INPUT <number>
sudo iptables -D OUTPUT <number>
~~~
> Para listar las reglas de NAT
~~~
sudo iptables -t nat -L -nv --line-numbers
~~~

### Configurar un cortafuegos perimetral en la máquina router-fw teniendo en cuenta los siguientes puntos:

* #### Política por defecto DROP para las cadenas INPUT, FORWARD y OUTPUT.
----------------------------------------------------

###### Limpiamos las tablas.

~~~
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -Z
sudo iptables -t nat -Z
~~~

###### Conexión ssh antes de estableces la politica por defecto en Drop para no perder la coonexión.

~~~
sudo iptables -A INPUT -s 172.22.0.0/16 -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -d 172.22.0.0/16 -p tcp -m tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

sudo iptables -A INPUT -s 172.23.0.0/16 -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -d 172.23.0.0/16 -p tcp -m tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

sudo iptables -A OUTPUT -p tcp -o eth1 -d 192.168.100.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth1 -s 192.168.100.0/24 --sport 22 -m state --state ESTABLISHED -j ACCEPT

sudo iptables -A OUTPUT -p tcp -o eth2 -d 192.168.200.0/24 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth2 -s 192.168.200.0/24 --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

###### Establecemos la política.

~~~
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
~~~


* #### Se pueden usar las extensiones que queremos adecuadas, pero al menos debe implementarse seguimiento de la conexión.

* #### Debemos implementar que el cortafuego funcione después de un reinicio de la máquina.

* #### Debes indicar pruebas de funcionamiento de todos las reglas.

* #### El cortafuego debe cumplir al menos estas reglas:
----------------------------------------------------

#### 1. La máquina router-fw tiene un servidor ssh escuchando por el puerto 22, pero al acceder desde el exterior habrá que conectar al puerto 2222.

##### Reglas

sudo iptables -I INPUT -p tcp -s 172.22.0.0/16 -m multiport --dports 2222:22 -j ACCEPT
sudo iptables -I OUTPUT -p tcp -d 172.22.0.0/16 -m multiport --sports 2222:22 -j ACCEPT

sudo iptables -A OUTPUT -p tcp -m multiport --dports 22:2222 -j ACCEPT

##### Comprobación
~~~
moralg@padano:~$ ssh -p 2222 debian@172.22.200.145
Linux dmz 4.19.0-6-cloud-amd64 #1 SMP Debian 4.19.67-2+deb10u1 (2019-09-20) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Dec 12 16:26:44 2019 from 172.23.0.54
debian@dmz:~$
~~~

#### 2. Desde la LAN y la DMZ se debe permitir la conexión ssh por el puerto 22 al la máquina router-fw.

##### Reglas

###### LAN
~~~
sudo iptables -A INPUT -s 192.168.100.10 --sport 22 -p tcp -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.100.10 --dport 22 -p tcp -j ACCEPT
~~~

###### DMZ
~~~
sudo iptables -A INPUT -s 192.168.200.10 --sport 22 -p tcp -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.200.10 --dport 22 -p tcp -j ACCEPT
~~~

##### Comprobación
~~~

~~~


#### 3. La máquina router-fw debe tener permitido el tráfico para la interfaz loopback.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 4. A la máquina router-fw se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT).

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 5. La máquina router-fw puede hacer ping a la LAN, la DMZ y al exterior.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 6. Desde la máquina DMZ se puede hacer ping y conexión ssh a la máquina LAN.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 7. Desde la máquina LAN no se puede hacer ping, pero si se puede conectar por ssh a la máquina DMZ.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 8. Configura la máquina router-fw para que las máquinas LAN y DMZ puedan acceder al exterior.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 9. La máquina LAN se le permite hacer ping al exterior.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 10. La máquina LAN puede navegar.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 11. La máquina DMZ puede navegar. Instala un servidor web, un servidor ftp y un servidor de correos.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 12. Configura la máquina router-fw para que los servicios web y ftp sean accesibles desde el exterior.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 13. El servidor web y el servidor ftp deben ser accesible desde la LAN y desde el exterior.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 14. El servidor de correos sólo debe ser accesible desde la LAN.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### 15. En la máquina LAN instala un servidor mysql. A este servidor sólo se puede acceder desde la DMZ.

##### Reglas
~~~

~~~

##### Comprobación
~~~

~~~

#### Si crees que necesitas más reglas de las que nos han indicado, describe porque pueden ser necesarias.
----------------------------------------------------

#### MEJORA: Utiliza nuevas cadenas para clasificar el tráfico.
----------------------------------------------------

#### MEJORA: Consruye el cortafuego utilizando nftables.





###### Hay que activar el 'ip_forward'
~~~
echo 1 > /proc/sys/net/ipv4/ip_forward
~~~



###### Ahora queremos establecer varias reglar para pemitir las conexiones ssh desde las maquinas LAN y DMZ

~~~
echo 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -I POSTROUTING -s 192.168.100.0/24 -o eth0 -p tcp --dport 22 -j MASQUERADE

sudo iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

sudo iptables -t nat -I POSTROUTING -s 192.168.200.0/24 -o eth0 -p tcp --dport 22 -j MASQUERADE

sudo iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~


###### Reinicio de la máquina

~~~
iptables-save > /etc/iproute2/rule.v4
~~~

~~~
# Generated by xtables-save v1.8.2 on Tue Dec 10 11:25:30 2019
*filter
:INPUT DROP [12:1876]
:FORWARD DROP [0:0]
:OUTPUT DROP [317:23506]
-A INPUT -s 172.22.0.0/16 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -s 172.23.0.0/16 -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -s 192.168.100.0/24 -i eth1 -p tcp -m tcp --sport 22 -j ACCEPT
-A INPUT -s 192.168.200.0/24 -i eth2 -p tcp -m tcp --sport 22 -j ACCEPT
-A FORWARD -i eth1 -o eth0 -p tcp -m tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
-A FORWARD -i eth0 -o eth1 -p tcp -m tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
-A OUTPUT -d 172.22.0.0/16 -p tcp -m tcp --sport 22 -j ACCEPT
-A OUTPUT -d 172.23.0.0/16 -p tcp -m tcp --sport 22 -j ACCEPT
-A OUTPUT -d 192.168.100.0/24 -o eth1 -p tcp -m tcp --dport 22 -j ACCEPT
-A OUTPUT -d 192.168.200.0/24 -o eth2 -p tcp -m tcp --dport 22 -j ACCEPT
COMMIT
# Completed on Tue Dec 10 11:25:30 2019
# Generated by xtables-save v1.8.2 on Tue Dec 10 11:25:30 2019
*nat
:PREROUTING ACCEPT [498:37760]
:INPUT ACCEPT [3:180]
:POSTROUTING ACCEPT [5:576]
:OUTPUT ACCEPT [311:22930]
-A POSTROUTING -s 192.168.100.0/24 -o eth0 -p tcp -m tcp --dport 22 -j MASQUERADE
COMMIT
# Completed on Tue Dec 10 11:25:30 2019
~~~

~~~
root@router-fw:~# nano /usr/local/bin/iptables.sh
~~~

~~~
#! /usr/bin/env bash
iptables-restore < /etc/iptables/rules.v4
~~~
