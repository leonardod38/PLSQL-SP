class Person:
    def set_details (self, name, age):
        self.name = name 
        self.age  = age 
    
    def display(self):
        print('I am ', self.name)
        
    def greet (self):
        if self.age < 80:
            print('Hello, how are you doing?')
        else:
            print('Hello, how do you do ?')        
        self.display()
        
    def get_old (self):
     age = 75 
    
    
p1 = Person()
p2 = Person()

p1.set_details('Jonh', 20)
p2.set_details('Jack', 90)

p1.greet()
p2.greet()
p1.get_old()


