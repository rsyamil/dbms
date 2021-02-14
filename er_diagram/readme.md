# ER Diagram - Dental practice

This is an ER diagram for a dental practice. While many of the attributes are self-explanatory, here I provide additional information about some of the components (comprising tables) and the values that the attributes can take:

## EMPLOYEES COMPONENT
Each staff hired at the firm must be designated to a position, that can be licensed by none, one or many boards. 

| **POSITION**                  | Description| 
| :-------------                |-----------|
| `position_type`               | One of : Front office worker, dental hygienist, regular dentist, periodontists, endodontists, orthodontists and dental surgeons.|
| `position_description`        | Job description and scope.|
| `position_monthly_salary`     | Minimum base salary paid to anyone with this position, total salary to any unique staff must include the `DESIGNATION.monthly_bonus_salary`.|

| **DESIGNATION**               | Description| 
| :-------------                |-----------|
| `start_date`                  | Start date of employment.|
| `end_date`                    | Leave Null if staff is still working at the practice.|
| `availability`                | States of staff - can be "on leave", "sabbatical", "on strike" etc.|
| `monthly_total_salary`        | Total salary paid to staff including the base salary, i.e. `POSITION.position_monthly_salary`. This depends on the hiring agreement, staff experience etc.|

| **CERTIFICATION**             | Description| 
| :-------------                |-----------|
| `cert_board`                  | One of https://www.dbc.ca.gov/licensees/dds/renewals.shtml or other boards.|
| `renewal_fee`                 | Cost of license renewal.|
| `license_expiry_date`         | Expiry date of licenses to be tracked.|

| **STAFF**                        | Description| 
| :-------------                   |-----------|
| `official_identification`        | Identification number of official real-life identity document.|
| `official_identification_type`   | Type of official real-life id provided, i.e. passport, driver's licence etc.|

## PATIENTS COMPONENT
Each patient (up to ~100) may have one or more documents generated for him/her over multiple visits. Each document can only belong to a patient. Examples of document are bite-wing scan, x-ray, dental charts etc. Each patient can have zero, or at most one insurance provider on file. 

| **DOCUMENT**      | Description| 
| :-------------    |-----------|
| `location`        | Location, path where the document is saved. Document may be of different types, i.e. pdf, tiff, jpg etc.|
| `description`     | Details about the document.|

| **INSURANCE_PROVIDER**      | Description| 
| :-------------              |-----------|
| `provider_id`               | Unique identifier for insurance providers.|
| `address`                   | For invoicing and claim purposes.|

| **PATIENT**       | Description| 
| :-------------    |-----------|
| `states`          | Either one of "contacted", "scheduled", "recently visited", "up for next visit" or "dormant".|

## RESERVATION COMPONENT
The dental practice has N rooms that can be reserved for a visit. Assume that each visit can potentially require no more than one room, each room is fully equipped for potentially different procedures and the rooms are labeled accordingly at the site. 

| **ROOM**          | Description| 
| :-------------    |-----------|
| `room_id`         | From one to N=8.|
| `status`          | Can be one of "ready" (i.e. sanitized and prepared), "in_use" or "out_of_use".|
| `type`            | Depends on the purpose of the room (i.e. operations, consultation).|

| **RESERVATION**   | Description| 
| :-------------    |-----------|
| `reservation_id`  | The id is only generated if there is no overlap in time slot for the staff (i.e. enabling `visit_id` to be generated) and room.|
| `res_date`        | Reservation date, i.e. the date when the room will be used. Must be the same as `VISIT.visit_date`.|
| `res_start_time`  | Reservation start time, i.e. the start time when the room will be used. At or after `VISIT.visit_start_time`.|
| `res_end_time`    | Reservation end time, i.e. the end time when the room will be used. At or before `VISIT.visit_end_time`.|
| `description`     | Optional, used to denote if special tools are needed in the room etc.|

In next iteration, needs to improve to prevent overlapping reservations.

## PROCEDURE COMPONENT
Each patient may schedule only one procedure per visit to avoid health complications. For practical bookkeeping, if a patient wishes to schedule multiple procedures in a day, another `VISIT` entity instance can be generated for the same day with different start and end times. 

| **PROCEDURE**        | Description| 
| :-------------       |-----------|
| `type`               | I.e. teeth cleaning, gum disease treatment, tooth extraction, whitening etc. Note that general consultation or routine check-up is also considered a procedure!|
| `total_cost`         | Total cost for the procedure including materials, manpower, utilities etc.|
| `total_duration`     | Useful to estimate duration of visit and duration of reservations.|
| `qualified_position` | Qualified position to perform said procedure as per positions in `POSITION`.|

## BILLING COMPONENT
Each `VISIT` instance generates a `BILL` instance and only one comprehensive bill. Each bill is unique to a visit. The bill can be paid through multiple instances of `PAYMENT` of different methods (i.e. through insurance and cash). `INVOICE` instance is generated to request payment from either provider or patient and results in a `PAYMENT` instance.

| **BILL**                  | Description| 
| :-------------            |-----------|
| `visit_id`                | References `VISIT` so necessary information can be found when generating or printing bills for patients.|
| `bill_date`               | Date when the bill is generated.|
| `total_charged`           | The total charged to patient, includes `PROCEDURE.total_cost`, medicine, local taxes, fees etc. In next iteration, need to add itemized billing.|
| `total_paid_patient`      | The total amount paid by patients and is derived/updated from summing `PAYMENT.total_paid` instances where `PAYMENT.payment_mode` is patient for this particular `bill_id`.|
| `total_paid_insurance`    | The total amount paid by insurance and is derived/updated from summing `PAYMENT.total_paid` instances where `PAYMENT.payment_mode` is insurance provider for this particular `bill_id`.|
| `due_date`                | Generally a month from `bill_date` but may be adjusted on case-to-case basis as noted in `notes`.|

| **INVOICE**       | Description| 
| :-------------    |-----------|
| `method`          | Invoice can be sent to `INSURANCE_PROVIDER` or `PATIENT`.|
| `address`         | Address of entity being billed. This is kept separate from the address of `INSURANCE_PROVIDER` or `PATIENT` so we can keep historical record.|
| `total_requested` | Depends on `PATIENT.coverage_type` and `PATIENT.amount_of_coverage` if requesting from `INSURANCE_PROVIDER`. The remaining balance is invoiced to `PATIENT`. If `PATIENT.provider_id` and `PATIENT.subscriber_id` are NULL, then full amount is invoiced to `PATIENT`.|

| **PAYMENT**       | Description| 
| :-------------    |-----------|
| `bill_id`         | Multiple payments (each payment must be invoiced!) can be made to settle a bill.|
| `payer_id`        | Entity instance paying for the bill, can be a bank representing the provider, anyone related to patient or patient him/her/themself.|
| `payment_mode`    | Cheque, cash, bitcoins etc.|

## OPEX COMPONENT
For monthly recurring expenses such as for general supplies, utilities, cleaning and food/water supplies (each uniquely identified as `item_id`), assume that the dental practice is connected to a network of suppliers (identified by `supplier_id`) that supply items needed. Ideally `ITEM` table and `SUPPLIER` table should be synchronized with the suppliers (some items may run out of stock, change price or no longer made). 

Building lease is part of `OPEX` where `SUPPLIER` will simply be the landlord and `ITEM` is the building. 

`CERTIFICATION.renewal_fee` is considered as OPEX.

| **ITEM**          | Description| 
| :-------------    |-----------|
| `name`            | Name of items, i.e. electricity, Skittles, morphine, bleach, needles, scalpel, cleaning services etc.|
| `price_per_unit`  | Price per unit in relevant measurement units, i.e. $/kWh, $/bag, $/dose, $/bottle, $/dozen, $/unit, $/hour etc.|

| **OPEX**          | Description| 
| :-------------    |-----------|
| `item_id`         | Identifier for item. The same `ITEM` may be purchased from different `SUPPLIER`.|
| `supplier_id`     | Identifier for supplier, assume that we have check for which `SUPPLIER` can supply what `ITEM` needed before any instance of `OPEX` is generated.|
| `total_cost`      | Total cost of this opex expense, i.e. `OPEX.quantity`x`ITEM.price_per_unit`.|
| `quantity`        | Quantity needed for a month.|
| `location`        | Location of files or contracts (i.e. pdf) saved.|

## CAPEX COMPONENT
For one-off (non-regular) payments for purchases from unique vendors. For big-ticket items such as furniture, dental equipment, software (for scheduling, billing etc), staff training etc.

| **CAPEX**         | Description| 
| :-------------    |-----------|
| `warranty_expiry` | Warranty expiration date for the item purchased.|
| `location`        | Location of files or contracts (i.e. pdf) saved.|

## LOAN COMPONENT
For loans taken by the practice, can be for general loan, auto-loan, mortgage etc. Multiple instances of `LOAN_INSTALLMENT` may be generated to capture past, current and future payments (which can be determined by the `LOAN_INSTALLMENT.payment_due_date`. Paid installments can be found as an instance in the `TRANSACTION` table. 

| **LOAN**             | Description| 
| :-------------       |-----------|
| `loan_type`          | One of "general", "mortgage", "vehicle", "holiday" etc.|
| `payment_due_date`   | When monthly payment is due, i.e. day of month.|
| `term_duration`      | How many months must the installments be paid for, i.e. 10 years = 120 months|
| `location`           | Location of files or contracts (i.e. pdf) saved.|

| **LOAN_INSTALLMENT**    | Description| 
| :-------------          |-----------|
| `amount`                | Monthly payment amount.|
| `payment_due_date`      | When monthly payment is due, i.e. day of month of year.|

## LEDGER COMPONENT
The ledger tracks all income and outpayments with a unique `transaction_id`. Every income and payments must have a `transaction_id` that verifies money has been received or paid into or from a company bank account. 

| **TRANSACTION**         | Description| 
| :-------------          |-----------|
| `amount`                | Amount transacted.|
| `date`                  | Date bank transaction occured.|
| `account_id`            | Account to receive or pay from.|

At most one of the foreign keys `capex_id`, `opex_id`, `payment_id` and `loan_installment_id` must have value. Expenses (i.e. `capex_id`, `opex_id` and `loan_installment_id`) has `amount` as NEGATIVE while incoming payments (i.e. `payment_id`) has `amount` as POSITIVE. In the next iteration, enforce EER on the transaction type as disjoint subtypes. 

# BUSINESS REQUIREMENTS
This section highlights how the conceptual database is designed to meet the needs of the dental practice:

| **REQUIREMENTS**               | Description| 
| :-------------                 |-----------|
| Tracking license expiry        | Query `CERTIFICATION` table and specify dates for `CERTIFICATION.license_expiry_date`.|
| View daily scheduled visits    | Query `VISIT` table and specify dates for `VISIT.visit_date`.|
| View daily billable income     | Query `BILL` table and specify dates for `BILL.bill_date`. Then project out `BILL.total_charged` and take the sum.|
| View monthly income            | Monthly income is interpreted as payments received, not billable income. Query `TRANSACTION` table and specify dates for `TRANSACTION.date` where `TRANSACTION.payment_id` is NOT NULL. Then project out `TRANSACTION.amount` and take the sum.|
| View monthly expenditure       | Query `TRANSACTION` table and specify dates for `TRANSACTION.date` where `TRANSACTION.capex_id`, `TRANSACTION.opex_id` or `TRANSACTION.loan_installment_id` is NOT NULL. Then project out `TRANSACTION.amount` and take the sum.|
| View monthly net income        | From above, take income - expenditure|








