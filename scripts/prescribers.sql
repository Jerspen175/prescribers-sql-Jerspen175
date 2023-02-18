-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT prescription.total_claim_count, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, drug.drug_name
FROM prescriber 
LEFT JOIN prescription
ON prescriber.npi=prescription.npi
LEFT JOIN drug
ON prescription.drug_name=drug.drug_name
WHERE prescription.total_claim_count IS NOT NULL
GROUP BY drug.drug_name, prescription.total_claim_count, prescriber.nppes_provider_last_org_name,prescriber.nppes_provider_first_name
ORDER BY prescription.total_claim_count DESC;
----David Coffey has the highest claim amount at 4,538.

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(prescription.total_claim_count)
FROM prescriber 
LEFT JOIN prescription
ON prescriber.npi=prescription.npi
WHERE prescription.total_claim_count IS NOT NULL
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, prescription.total_claim_count
ORDER BY prescription.total_claim_count DESC;
----David Coffey, Family Practice, 4,538.
-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count)
FROM prescription
LEFT JOIN drug
USING(drug_name)
LEFT JOIN prescriber 
USING(npi)
GROUP BY prescription.total_claim_count, specialty_description
ORDER BY prescription.total_claim_count DESC;
----FENOFIBRATE has the most claims at 5,859.

--     b. Which specialty had the most total number of claims for opioids?
SELECT drug.opioid_drug_flag,drug.drug_name, SUM(prescription.total_claim_count) AS opioids_claims, prescriber.specialty_description
FROM prescription
LEFT JOIN drug
USING(drug_name)
LEFT JOIN prescriber
USING(npi)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescription.total_claim_count, drug.opioid_drug_flag, drug.drug_name, prescriber.specialty_description
ORDER BY prescription.total_claim_count DESC;
----Family Practice has the highest number of claims, 4,538.

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT prescriber.specialty_description, COUNT(prescription.drug_name)
FROM prescription
INNER JOIN prescriber
USING(npi)
WHERE prescriber.specialty_description IS NOT NULL AND prescription.drug_name IS NULL
GROUP BY prescriber.specialty_description;
--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, prescription.total_drug_cost
FROM drug
LEFT JOIN prescription
ON prescription.drug_name = drug.drug_name
WHERE prescription.total_drug_cost IS NOT NULL 
ORDER BY prescription.total_drug_cost DESC;
----Pirfenidone has the highest drug cost at $2,829,174.30

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost/prescription.total_day_supply), 2) AS cost_per_day
FROM drug
LEFT JOIN prescription
ON prescription.drug_name = drug.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC;
-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
  (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
  ELSE 'neither' END) AS drug_type 
FROM drug
GROUP BY drug_name, opioid_drug_flag, antibiotic_drug_flag;
   
	   
--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT drug.drug_name, total_drug_cost AS money,
  (CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
  ELSE 'neither' END) AS drug_type 
FROM drug
LEFT JOIN prescription
ON prescription.drug_name = drug.drug_name 
WHERE opioid_drug_flag != 'neither' AND antibiotic_drug_flag != 'neither'
GROUP BY drug.drug_name, opioid_drug_flag, antibiotic_drug_flag, total_drug_cost;
----More money was spent on opioids.
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT cbsa, COUNT(state)
FROM cbsa
LEFT JOIN fips_county
USING(fipscounty)
WHERE state = 'TN' 
GROUP BY state, cbsa;
---Tennessee has 42 CBSAs.
--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, population
FROM cbsa
LEFT JOIN zip_fips
USING(fipscounty)
LEFT JOIN population 
USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname, population
ORDER BY population ASC;
----Memphis, TN-MS-AR has the largest has the largest at 937,847. Nashville-Davidson--Murfreesboro--Franklin, TN has the smallest at 8,773.

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT MAX(population), county, cbsa
FROM population
LEFT JOIN fips_county 
USING(fipscounty)
LEFT JOIN cbsa
USING(fipscounty)
WHERE cbsa IS NULL
GROUP BY population, county, cbsa
ORDER BY population DESC
LIMIT 5;
----Sevier has the largest population at 95,523 and is not included in the cbsa.
-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= '3000'
GROUP BY drug_name, total_claim_count
ORDER BY total_claim_count DESC;
-------
--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, total_claim_count, opioid_drug_flag, 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'not_an_opioid' END
FROM prescription
LEFT JOIN drug
USING(drug_name)
WHERE total_claim_count >= '3000'
GROUP BY drug_name, total_claim_count, opioid_drug_flag
ORDER BY total_claim_count DESC;
----HYDROCODONE-ACETAMINOPHEN and OXYCODONE HCL are the only two that are opioids.

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, total_claim_count, opioid_drug_flag, nppes_provider_last_org_name, nppes_provider_first_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'not_an_opioid' END
FROM prescription
LEFT JOIN drug
USING(drug_name)
LEFT JOIN prescriber
USING(npi)
WHERE total_claim_count >= '3000'
GROUP BY drug_name, total_claim_count, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
ORDER BY total_claim_count DESC;

-----

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT drug.drug_name, specialty_description, nppes_provider_city, opioid_drug_flag
FROM drug
CROSS JOIN prescriber
WHERE nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y' AND specialty_description = 'Pain Management';
--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.