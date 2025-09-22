--this assignment is out 20
--2 marks per question

/* Q1
Return all owners. Show OwnerID, FullName, Phone, Email.
2/2
*/

select OwnerID, FullName, Phone, Email 
from Owner


/* Q2
Return all pets where the species is 'Dog'. Show PetID, Name, Species, Breed.

2/2
*/

select p.PetID, p.Name, p.Species, p.Breed
from Pet p
where p.Species = 'Dog' --if you forgot this, -1 (so your mark for the question would be 1/2)

/* Q3
Return all microchips that have not been scanned yet. Show ChipID, ChipNumber, ImplantedDate, LastScanDate.
2/2
**/

select ChipID, ChipNumber, ImplantedDate, LastScanDate
from Microchip
where LastScanDate is null

/* Q4
List pets that have a microchip. Show PetID, Name, Species, ChipNumber, ImplantedDate.
*/

select p.PetID, p.Name, p.Species, m.ChipNumber, m.ImplantedDate
from Microchip m inner join Pet p on m.PetID = p.PetID 

select p.PetID, p.Name, p.Species, m.ChipNumber, m.ImplantedDate
from Pet p join Microchip m on p.PetID = m.PetID 

/* Q5
List pets that do not have a microchip. Show PetID, Name, Species.
*/
select p.PetID, p.Name, p.Species
from Pet p left join Microchip m on p.PetID = m.PetID
where m.ChipID  is null

select p.PetID, p.Name, p.Species
from Microchip m right join Pet p on m.PetID = p.PetID 
where m.ChipID  is null

/* Q6
List all microchips with their pet details when present.
*/

select * --m.ChipNumber, m.PetID 
from Microchip m left join Pet p on m.PetID = p.PetID 

select *
from Pet p right join Microchip m on p.PetID = m.PetID 


/* Q7
List each owner with their pets. Show Owner FullName, Pet Name, Species, Breed.
*/

select o.FullName, p.Name as 'Pet Name', p.Species, p.Breed
from Owner o inner join Pet p on o.OwnerID = p.OwnerID 


/* Q8
Return all owners with their pet information when it exists. Show Owner FullName, Pet Name, Species.
*/

select o.FullName, p.Name as 'Pet Name', p.Species, p.Breed
from Owner o left join Pet p on o.OwnerID = p.OwnerID 

/* Q9
Return owners who currently have no pets. Show OwnerID, FullName, Email.
*/

select o.OwnerID, o.FullName, o.Email
from Owner o left join Pet p on o.OwnerID = p.OwnerID
where p.PetID is null

/* Q10
Return all owners who have a pet where the species is 'Cat'. Show Owner FullName, Pet Name, Species.
*/

select o.FullName as 'Owner Name', p.Name as 'Pet Name', p.Species 
from Owner o join Pet p on o.OwnerID = p.OwnerID 
where p.Species = 'Cat'
