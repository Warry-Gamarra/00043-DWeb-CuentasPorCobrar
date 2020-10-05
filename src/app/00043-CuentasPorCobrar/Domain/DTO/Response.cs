using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.DTO
{
    public class Response
    {
        public bool Value { get; set; }
        public string Action { get; set; }
        public string Redirect { get; set; }
        public string Message { get; set; }
        public string Icon { get; set; }
        public string Color { get; set; }
        public string CurrentID { get; set; }
    }
}
