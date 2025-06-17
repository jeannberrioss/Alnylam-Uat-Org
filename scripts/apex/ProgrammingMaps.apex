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

String[] myStringArray = new String[]{'Hello', 'World', 'Apex'};
for (String myString : myStringArray) {
    System.debug(myString);
    System.debug('Length of ' + myString + ' is ' + myString.length());
}

// I will delcare an array without initializing it
String[] myUninitializedArray;

// I will create a NullPointerException by trying to access an element of the uninitialized array
try {
    System.debug(myUninitializedArray[0]);
} catch (NullPointerException e) {
    System.debug('Caught a NullPointerException: ' + e.getMessage());
} 