public class SchemaPicklistFields {
  public String defaultOption;

  public List<SelectOption> getPicklistOptions(
    string objectName,
    String fieldName,
    String viewAllValue
  ) {
    List<SelectOption> options = new List<SelectOption>();
    sObjectType objectType = Schema.getGlobalDescribe().get(objectName);
    if (objectType == null)
      return options;

    Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
    Schema.SObjectField field = objDescribe.fields.getMap().get(fieldName);
    if (field == null)
      return options;

    if (viewAllValue != '' && viewAllValue != null)
      options.add(new SelectOption(viewAllValue, 'View All'));
    for (Schema.PicklistEntry i : field.getDescribe().getPickListValues()) {
      options.add(new SelectOption(i.getLabel(), i.getValue()));
      if (i.isDefaultValue())
        defaultOption = i.getValue();
    }

    return options;
  }
}
