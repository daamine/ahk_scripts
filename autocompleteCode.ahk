

:*:printc::printf('%d\n', num);

:*:logjs::
{
Send, console.log();{Left}{Left}
Return
}

:*:printjava::
{
Send, System.out.println(){Left 1}
Return
}

:*:writecs::
{
Send, Console.WriteLine();{Left}{Left}
Return
}

::mount__::
{
Send, mount -t nfs -o rsize=4096,wsize=8192,tcp,nolock 192.168.0.8:/user /mnt/nfs
Return
}

::rsync__::
{
Send, rsync  --no-perms --chmod=ugo=rwx -e 'ssh -p 2222' -avzh . server:/home/user
Return
}

::forC::
(
for (int i = 0; i < n; i++) {
)

::forjava::
{
SendRaw, 
(
for (int i = 0; i < n; i++) {

}
)
send, {Up} 
Return
}

::forJs::
(
for (let i = 0; i < arr.length; i++) {
)

::forPy::for i in range(0, len(arr)):

:*:forMatlab::
(
for i = 1:step:length(arr)

end
)
::switchJs::
(
switch() {
case 0:

break;
case 1:

break;
default:
)


:*:datenow::
{
  FormatTime, DateString, , yyyy-MM-dd
  Send %DateString%
  Return
}

:*:timenow::
{
  FormatTime, DateString, , HH:mm
  Send %DateString%
  Return
}
