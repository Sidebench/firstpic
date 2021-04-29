public class PaginationClass {
  public List<sObject> records = new List<sObject>();

  public List<sObject> first(List<sObject> allRecords, Integer limitSize) {
    system.debug('PC first allRecords = ' + allRecords);
    records.clear();
    if (limitSize <= allRecords.size()) {
      for (Integer i = 0; i < limitSize; i++)
        records.add(allRecords.get(i));
    } else {
      for (Integer i = 0; i < allRecords.size(); i++)
        records.add(allRecords.get(i));
    }
    return records;
  }

  public List<sObject> next(
    List<sObject> allRecords,
    Integer counter,
    Integer limitSize
  ) {
    records.clear();
    if ((counter + limitSize) <= allRecords.size()) {
      for (Integer i = counter - 1; i < (counter + limitSize); i++)
        records.add(allRecords.get(i));
    } else {
      for (Integer i = counter; i < allRecords.size(); i++)
        records.add(allRecords.get(i));
    }
    return records;
  }

  public List<sObject> previous(
    List<sObject> allRecords,
    Integer counter,
    Integer limitSize
  ) {
    records.clear();
    Integer totalSize = counter + limitSize;
    if (counter + limitSize > allRecords.size())
      totalSize = allRecords.size();
    else
      for (Integer i = counter; i < totalSize; i++)
        records.add(allRecords.get(i));
    return records;
  }

  public List<sObject> last(
    List<sObject> allRecords,
    Integer counter,
    Integer limitSize
  ) {
    records.clear();
    for (Integer i = counter; i < allRecords.size(); i++)
      records.add(allRecords.get(i));
    return records;
  }

  public Integer getLastCounter(
    Integer counter,
    Integer limitSize,
    Integer totalSize
  ) {
    system.debug('counter = ' + counter);
    system.debug('limitSize = ' + limitSize);
    system.debug('totalSize = ' + totalSize);
    if (math.mod(totalSize, limitSize) == 0) {
      counter = limitSize * ((totalSize / limitSize) - 1);
    } else if (math.mod(totalSize, limitSize) != 0) {
      counter = limitSize * ((totalSize / limitSize));
    }
    if (totalSize == 0)
      counter = 0;
    return counter;
  }

  public String getRecordCount(
    Integer counter,
    Integer limitSize,
    Integer totalSize
  ) {
    String rc = '';
    if (totalSize == 0)
      return rc;
    rc += (counter + 1) + ' - ';
    if ((counter + limitSize) <= totalSize)
      rc += counter + limitSize;
    else
      rc += totalSize;
    rc += ' of ' + totalSize;
    return rc;
  }

  public Boolean getDisableNext(
    Integer counter,
    Integer limitSize,
    Integer totalSize
  ) {
    if ((counter + limitSize) >= totalSize)
      return true;
    else
      return false;
  }

  public Boolean getDisablePrevious(Integer counter) {
    if (counter == 0)
      return true;
    else
      return false;
  }
}
