@isTest
public class TestCommunityDebugger {
  static testMethod void test() {
    Test.setCurrentPageReference(new PageReference('Page.CommunityDebugger'));
    CommunityDebuggerCtrl ctrl = new CommunityDebuggerCtrl();
    ctrl.fetchFailingPage();
  }
}
