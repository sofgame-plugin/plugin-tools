#ifndef ACCOUNTINFOACCESSINGHOST_H
#define ACCOUNTINFOACCESSINGHOST_H


class AccountInfoAccessingHost
{
public:
	virtual ~AccountInfoAccessingHost() {}

	virtual QString getStatus(int account) = 0;
	virtual QString getStatusMessage(int account) = 0;
	virtual QString proxyHost(int account) = 0;
	virtual int proxyPort(int account) = 0;
	virtual QString proxyUser(int account) = 0;
	virtual QString proxyPassword(int account) = 0;
	virtual QString getJid(int account) = 0;  //if account out of range return "-1"
	virtual QString getId(int account) = 0;  //if account out of range return "-1"
	virtual QString getName(int account) = 0;  //if account out of range return ""
	virtual QStringList getRoster(int account) = 0; //if account out of range return List with one element, value "-1"
};

Q_DECLARE_INTERFACE(AccountInfoAccessingHost, "org.psi-im.AccountInfoAccessingHost/0.1");

#endif // ACCOUNTINFOACCESSINGHOST_H
