import dns.resolver
import time
import random

uri_format = input("URL Format (use '%d' to substitute in $i): ")
start_range = input("Start value [0]: ") or "0"
end_range = input("End value [100]: ") or "100"
step = input("Step [1]: ") or "1"
play_nice = input("Play nice with DNS servers (may be significantly slower) [y]: ") or "y"
dns_server = input("DNS IP [default]: ") or None
output_location = input("Output location [output.txt]: ") or "output.txt"

if not start_range.isdigit() or not end_range.isdigit() or not step.isdigit():
    print("Invalid range or step")
    exit()

start_range = int(start_range)
end_range = int(end_range)
step = int(step)

iterator = range(start_range, end_range, step)

if play_nice == "y":
    def _sleep():
        time.sleep(random.randint(1, 10) / 10)
else:
    def _sleep():
        pass

resolver = dns.resolver.Resolver()
if dns_server:
    resolver.nameservers = dns_server.split(",")

with open(output_location, "w") as output:
    for i in iterator:
        formatted = uri_format.replace("%d", str(i))
        print(f"{formatted}: ", end="")
        try:
            response = resolver.resolve(formatted)
        except dns.resolver.NXDOMAIN:
            print("NXDOMAIN")
        except dns.resolver.NoAnswer:
            print("No answer")
        except dns.resolver.NoNameservers:
            print("No nameservers")
        except dns.resolver.LifetimeTimeout:
            print("Timeout")
        except dns.resolver.YXDOMAIN:
            print("YXDOMAIN")
        except dns.exception.Timeout:
            print("Timeout")
        except dns.exception.DNSException:
            print("DNSException")
        else:
            answer = response
            if isinstance(answer, dns.resolver.Answer) and list(answer):
                if any(y.address == "0.0.0.0" for y in answer):
                    print("Already blocked")
                else:
                    print("OK")
                    output.write(f"{formatted}\n")
            else:
                print("No IPs")
        _sleep()