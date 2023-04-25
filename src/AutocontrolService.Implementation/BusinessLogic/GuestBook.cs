using PlantiT.Base.ServiceBootstrapping.Validation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AutocontrolService.Implementation.BusinessLogic
{
    /// <summary>
    /// Stores names of people.
    /// 
    /// TODO for template-users: This is an example service for dependency injection and should be removed once understood!
    /// </summary>
    public class GuestBook
    {
        private List<GuestBookEntry> entries;

        /// <summary>
        /// Initializes the guest-book with all guests that where here before.
        /// </summary>
        public GuestBook()
        {
            entries = new List<GuestBookEntry>()
            {
                new GuestBookEntry { Name = "Christian", Date = new DateTime(2018,04,30) },
                new GuestBookEntry { Name = "Marianne", Date = new DateTime(2018,04,30) },
                new GuestBookEntry { Name = "Homer", Date = new DateTime(1955,10,05) },
                new GuestBookEntry { Name = "Tom", Date = new DateTime(2038,04,30) },
                new GuestBookEntry { Name = "Dennis", Date = new DateTime(2020,03,20) },
                new GuestBookEntry { Name = "Benjamin", Date = new DateTime(2020, 03, 30) },
                new GuestBookEntry { Name = "Lorenz", Date = new DateTime(2020, 08, 24) },
                new GuestBookEntry { Name = "Jonathan", Date = new DateTime(2020, 08, 24) }
            };
        }

        /// <summary>
        /// Everyone who was a guest in this session.
        /// </summary>
        public IReadOnlyList<GuestBookEntry> Entries
        {
            get { return entries; }
            set { entries = value.ToList(); }
        }

        /// <summary>
        /// Add an entry for a guest who just visited.
        /// </summary>
        /// <param name="entry">The new entry to add.</param>
        public void AddEntry(GuestBookEntry entry)
        {
            entries.Add(entry);
        }

        /// <summary>
        /// Get a specific guest by index.
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public GuestBookEntry GetEntry(int index)
        {
            return entries[index];
        }

        /// <summary>
        /// Delete a specific guest.
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public void DeleteEntry(int index)
        {
            entries.RemoveAt(index);
        }
    }

    /// <summary>
    /// An entry in a guestbook.
    /// </summary>
    public class GuestBookEntry
    {
        /// <summary>
        /// Instanciation of a guest-book entry.
        /// IMPORTANT! Model classes must either have no constructor defined (that will mean they automatically receive a parameterless default-constructor at compile-time)
        /// OR if they have constructors with parameters, they always also need a parameterless constructor, like the one below. Otherwise automatic deserialisation cannot be done.
        /// The constructor below serves as a memorial to this fact and can be deleted, once the information here is understood.
        /// </summary>
        public GuestBookEntry()
        {

        }

        /// <summary>
        /// Name of the person.
        /// </summary>
        [OnlyUnicodeLetters]  // To learn more about this, lookup Manual chapter "API-Input-Validation" on the Developer-Manual
        public string Name { get; set; }

        /// <summary>
        /// Date of entry.
        /// </summary>
        public DateTime Date { get; set; }
    }
}
