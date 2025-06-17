string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

/* The below map is initialized with two key-value pairs. */
map<id,string> ThisIsMyMap = new map<id,string>{
    '001xx000003DHPHAA4' => 'Account Name 1',
    '001xx000003DHPHAA5' => 'Account Name 2'
};

/* 'put' method adds a new key-value pair */
ThisIsMyMap.put('001xx000003DHPHAA6', 'Account Name 3');
System.debug(ThisIsMyMap);
System.debug(ThisIsMyMap.get('001xx000003DHPHAA6'));
System.debug(ThisIsMyMap.size());
System.debug(ThisIsMyMap.values()); /// Returns a list of values in the map

String[] myStringArray = new String[]{'Hello', 'World', 'Apex'};
for (String myString : myStringArray) {
    System.debug(myString);
    System.debug('Length of ' + myString + ' is ' + myString.length());
}

// I will delcare an array without initializing it
String[] myUninitializedArray = new String[1];
myUninitializedArray[0] = 'This is a test string';

/* Try Catch block to handle potential NullPointerException */
try {
    System.debug(myUninitializedArray[0]);
} catch (NullPointerException e) {
    System.debug('Caught a NullPointerException: ' + e.getMessage());
} 