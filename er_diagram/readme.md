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
| `monthly_bonus_salary`        | Additional salary paid to staff on top of the base salary, i.e. `POSITION.position_monthly_salary`. This depends on the hiring agreement, staff experience etc.|

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
Each patient may have one or more documents generated for him/her over multiple visits. Each document can only belong to a patient. Examples of document are bite-wing scan, x-ray, dental charts etc.

| **DOCUMENT**      | Description| 
| :-------------    |-----------|
| `location`        | Location, path where the document is saved. Document may be of different types, i.e. pdf, tiff, jpg etc.|
| `description`     | Details about the document.|



