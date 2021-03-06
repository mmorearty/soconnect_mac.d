#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=10hz

inline int af_inet = 2;		/* AF_INET defined in bsd/sys/socket.h */
inline int af_inet6 = 30;	/* AF_INET6 defined in bsd/sys/socket.h */

dtrace:::BEGIN
{
	/* Add translations as desired from /usr/include/sys/errno.h */
	err[0]            = "Success";
	err[EINTR]        = "Interrupted syscall";
	err[EIO]          = "I/O error";
	err[EACCES]       = "Permission denied";
	err[ENETDOWN]     = "Network is down";
	err[ENETUNREACH]  = "Network unreachable";
	err[ECONNRESET]   = "Connection reset";
	err[ECONNREFUSED] = "Connection refused";
	err[ETIMEDOUT]    = "Timed out";
	err[EHOSTDOWN]    = "Host down";
	err[EHOSTUNREACH] = "No route to host";
	err[EINPROGRESS]  = "In progress";

	printf("%-6s %-16s %-8s %-20s %-5s %8s %s\n", "PID", "PROCESS", "FAM",
	    "ADDRESS", "PORT", "LAT(us)", "RESULT");
}

syscall::connect*:entry
{
	/* assume this is sockaddr_in until we can examine family */
	this->s = (struct sockaddr_in *)copyin(arg1, sizeof (struct sockaddr));
	this->f = this->s->sin_family;
}

syscall::connect*:entry
/this->f == af_inet/
{
	self->family = "AF_INET";
	self->port = ntohs(this->s->sin_port);
	self->address = inet_ntoa((uint32_t *) &this->s->sin_addr);
	self->start = timestamp;
}

syscall::connect*:entry
/this->f == af_inet6/
{
	/* refetch for sockaddr_in6 */
	this->s6 = (struct sockaddr_in6 *) copyin(arg1, sizeof (struct sockaddr_in6));

	self->family = "AF_INET6";
	self->port = ntohs(this->s6->sin6_port);
	self->address = inet_ntoa6(&this->s6->sin6_addr);
	self->start = timestamp;
}

syscall::connect*:return
/self->start/
{
	this->delta = (timestamp - self->start) / 1000;
	this->errstr = err[errno] != NULL ? err[errno] : lltostr(errno);
	printf("%-6d %-16s %-8s %-20s %-5d %8d %s\n", pid, execname,
	    self->family, self->address, self->port, this->delta, this->errstr);
	self->family = 0;
	self->address = 0;
	self->port = 0;
	self->start = 0;
}
