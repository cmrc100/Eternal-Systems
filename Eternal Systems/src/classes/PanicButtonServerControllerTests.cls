@isTest (SeeAllData = true)
public class PanicButtonServerControllerTests {
    static testMethod void testData() {
		List<SoundClip__c> SoundClips;
        SoundClips = PanicButtonServerController.getMedia();
		System.assertNotEquals(true,SoundClips.isEmpty());
    }
}