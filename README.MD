### All Ninjas
Localization addon for [Shinobi Story](https://shinobistory.com/) project

### Localization principles
1. If something is not translated, then the original should be displayed, not emptiness. This will help determine what still needs to be translated.
2. Not quests, but missions. 

### Small notes on working with mission text
If you need to go to the next line, use the `$B` symbol. For example:
>"The Village paid for a shipment of vegetables from the farmers in Tiller's Town. They have yet to deliver.$B$BPlease go to fetch that shipment bring it back."  

Double `$B$B` mean one new line, and one blank line:  
![image](https://i.imgur.com/HYvV3Rb.png)
***
Don't forget that the character has his own gender. In one sentence in two different languages, references can have different genders. In some languages, verbs do not change based on the gender of the subject. This means that the verb form remains the same whether a man or a woman is performing the action. However, in other languages, verbs often change based on the gender of the subject. So, in a sentence like `A client would like you to pick his vegetables for him,` the verb `pick` does not indicate the gender of the person who is supposed to do the picking. But when translating this sentence into a language where verbs change based on gender, we might need to adjust the verb form to match the gender of the person who is supposed to pick the vegetables. This is a feature of many languages that have gendered grammar. It adds a layer of complexity to translation and sometimes requires additional context to get right.  
In this case, you can modify the text:
> "Клиент хотел бы, чтобы ты $Gсобрал:собрала; для него овощей.$B$BОвощи посажены в Академии."

You can see `$Gсобрал:собрала;` construction, where `собрал` displayed if character has male gender, or `собрала` if female gender.