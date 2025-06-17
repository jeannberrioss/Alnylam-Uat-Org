string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

/* The above map is initialized with two key-value pairs. */
map<id,string> ThisIsMyMap = new map<id,string>{
    '001xx000003DHPHAA4' => 'Account Name 1',
    '001xx000003DHPHAA5' => 'Account Name 2'
};

/* 'put' method adds a new key-value pair */
ThisIsMyMap.put('001xx000003DHPHAA6', 'Account Name 3');
System.debug(ThisIsMyMap);
System.debug(ThisIsMyMap.get('001xx000003DHPHAA6'));

String[] myStringArray = new String[]{'Hello', 'World', 'Apex'};
for (String myString : myStringArray) {
    System.debug(myString);
    System.debug('Length of ' + myString + ' is ' + myString.length());
}

// I will delcare an array without initializing it
String[] myUninitializedArray;
