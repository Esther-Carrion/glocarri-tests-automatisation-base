import com.intuit.karate.junit5.Karate;

class KarateBasicTest {
    static {
        System.setProperty("karate.ssl", "true");
    }
    
    @Karate.Test
    Karate testMarvelAPI() {
        return Karate.run("classpath:features/TestMarvel.feature");
    }

}
