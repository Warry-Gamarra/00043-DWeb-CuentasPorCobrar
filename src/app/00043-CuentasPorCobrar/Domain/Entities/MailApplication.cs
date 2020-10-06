using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class MailApplication
    {
        public int ID { get; set; }
        public string Address { get; set; }
        public string Password { get; set; }
        public string SecurityType { get; set; }
        public string HostName { get; set; }
        public int Port { get; set; }
        public bool Enabled { get; set; }
        public DateTime FecUpdated { get; set; }
    }
}
