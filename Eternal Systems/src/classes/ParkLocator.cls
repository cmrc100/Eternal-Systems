public class ParkLocator {

    public static list<string> country(string countrySearch ) {
        ParkService.ParksImplPort parks = 
            new ParkService.ParksImplPort();
        return parks.byCountry(countrySearch);
    }
}