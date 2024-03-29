# Various (cyber) tools/scripts

You'll find tools and scripts that I coded to simplify your life. You can improve them (optimize the code, rethink some aspects) and create a PR if you want !

## Volatility easy install

Script has moved here : https://github.com/Abyss-W4tcher/volatility-scripts/tree/master/vol_ez_install

## "Meterpreter session"/"Metasploit" via ngrok

Getting a meterpreter tcp session could be a real nightmare behind a router you don't control, or just don't want to setup. 
To bypass that, you may have tried to use ngrok as a "VPS", in a normal reverse shell setup. However, metasploit needs to listen on a local interface, and doesn't seem to have some sort of "ngrok compatibility".

After a long time just giving up on getting cool and easy meterpreter sessions (which implies having to deal with obscure payloads manually), I decided to find a solution.

Here is an example :

1. Start ngrok in another terminal : `ngrok tcp 4444`. e.g. : you get "7.tcp.eu.ngrok.io:17500"
2. Launch the script, which will create a dummy interface (ngrok public IP as address) and a socat port forwarder (local port 4444 -> local port 17500)
3. Specify ngrok IP as LHOST and ngrok port as LPORT in metasploit
4. Launch your exploit
5. Victim executes reverse TCP payload and tries to instantiate handshake with ngrok
6. ngrok transfers the traffic to you through the tunnel
7. You receive it on port 4444
8. The socat binder forwards traffic from port 4444 to 17500
9. Metasploit intercepts it 
10. The meterpreter session instantiates
11. Once you are done, CTRL+C the script and the dummy interface will be removed.
    
What happens here, is that we "trick" metasploit into using the dummy interface as the one to listen to.  
Doing so, the connect-back IP and PORT sent in the payload will be ngrok IP+PORT. The victim will contact this IP, which will then redirect to our machine via tunnel. 

You now have the exact same result as forwarding port on your router, but securely and easily.

/!\ Important : If you need multiple meterpreter sessions at the same time, you'll need to launch a new ngrok connection (I suggest you to use the standalone binary for this, just modify the config file to another account). Careful though, that the script gets local ngrok interface on port 4040. However, if the port is already used, it will increment (e.g. 4041).  
So you'll have to launch the script a second time, with taking care of modifying this port in the code (just CTRL+F 4040).

**Help** :

`Usage : meterpreter_ngrok.sh local_port_used_by_ngrok dummy_interface_name (optional). Ex: meterpreter_ngrok.sh 4444 ethngrok`
