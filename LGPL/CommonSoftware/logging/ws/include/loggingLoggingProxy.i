template<>
void LoggingProxy::AddData<>(const ACE_TCHAR *szName, const ACE_TCHAR *szValue);

template<class... Args>
void LoggingProxy::AddData(const ACE_TCHAR *szName, const ACE_TCHAR *szFormat, Args... argp) {
  ACE_TCHAR data[ADD_DATA_VALUE_MAX];
  snprintf (data, 10, szFormat, argp...);
  tss.addData(szName, data);
}

