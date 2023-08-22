# Infrastructure-as-code (IaC)

## Definition of Infrastructure-as-code
Infrastructure-as-Code (IaC) is the managing and provisioning of infrastructure through code instead of through manual processes. Traditionally, a web UI in the browser or other manual steps were used to create and manage virtual cloud resources. This method is prone to error, difficult to repeat and time consuming. 

IaC offers a repeatable and more exact approach to creating and managing cloud infrastructure. Code that contains how you want your infrastructure to be configure is written and then is “run” using a plan/apply pattern. The plan step creates a blueprint of what infrastructure will be created and deployed. After a manual review, the apply step will then execute the plan. Some IaC tools use a stateful architecture, meaning that it keeps track of what infrastructure it is managing and uses that as a reference to know what changes need to be made.

## Tools and Techniques
Using IaC tools greatly enhances your ability to produce reliable software environments. It allows you to define the virtual hardware your application needs as code, which can be checked into source control and appropriately versioned. Terraform, CloudFormation(AWS only) and Ansible are examples of IaC tools. While many parts of your IaC will be specific to one cloud provider  Terraform is not, and can be used to deploy code to multiple cloud providers. 

An important principle for good IaC is _idempotence_. It is a property that describes a set of actions that will yield the same result no matter how many times the actions takes place. A real world example is pushing an elevator call button. No matter how many times it is pushed the elevator will arrive on the same schedule that was determined after the initial button push. Programming examples include hash functions and a http GET request. Using the same inputs to the system will return the same outputs from the system no matter the number of times it is repeated (assuming no external actions are taken on the system).

> Idempotence: the property of certain operations in mathematics and computer science whereby they can be applied multiple times without changing the result beyond the initial application. The concept of idempotence arises in a number of places in abstract algebra and functional programming.

When IaC is written with idempotency in mind, it can be reliably used because the code will only take operations to reach the desired outcome. If that outcome already exists then no operations are needed. 

When working with infrastructure you should always have a rollback path. Properly versioning and using  source control in conjunction with IaC can provide such an assurance. When a rollback is needed, revert to the previous working version of the code and apply. Another way to maintain a rollback path is using _immutable infrastructure_. Immutable infrastructure is the concept that you don’t change your infrastructure or upgrade it directly. Instead, new infrastructure is creating that will replace the old stuff. When a problem with the new infrastructure occurs, the old stuff is still available to use without much effort.

## Exercises 
Now try to work through the exercises for this chapter:
- [Intro to Terraform](exercises/01-intro-to-terraform/)
- [Check out the full course for more exercises](https://blog.stowellcrew.com/Getting-Started-in-DevOps-c84d8a7aa462487cb81c7963cb16d76c)