
Inspiration:
We were inspired to create this project because we regularly found ourselves searching for specific items with specific use cases in college, and we longed for a product that solved this issue.

What it does:
DormDash allows merchants to display their items for rent and allows customers to search for items to rent and manage their rented items. DormDash seamlessly manages the exchange and return of the item. DormDash also provides a rating for the customer's creditworthiness and the quality of the product.

How we built it:
We built DormDash using Capital One's robust NESSIE API to manage our database of customers and merchants. We also created our front end and back end using Flask, PostgreSQL, and Swift. We used a pre-trained model from HuggingFace.co to conduct sentiment analysis on sample reviews of various products, which produced a weighted average of ratings for the rented product, which ranged from 1 to 5. We also used Python libraries such as Scikit-Learn, pandas, and matplotlib to find a scaled model that used the difference between the payment due date and the actual payment date of bills to generate a rating for each customer on their creditworthiness

Challenges we ran into:
One of the biggest challenges we faced was finding an adequate dataset to train/test our ML model. The datasets we encountered either didn't include the data we desired or were strewn with skewed/biased data. We then tried to materialize our own dataset; however, we quickly discovered that our randomly generated data would not have a correlation. Database engineering was also a challenge, with database uniformity between NESSIE and our own being a highlight. In some instances, we were inconsistent with our data names, causing issues along the tech stack.

Accomplishments that we're proud of:
One of our biggest accomplishments is our front-end design. We took meticulous time and effort to craft the user interface, and the result is a profound design that invites the user to interact with the app. We are also very proud of the number of features we have implemented. Relative to the complexity of our project, we accomplished much more than we imagined during our ideation period.
