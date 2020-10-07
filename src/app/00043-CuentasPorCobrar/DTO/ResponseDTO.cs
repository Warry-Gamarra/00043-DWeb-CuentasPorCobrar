using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DTO
{
    public class ResponseDTO
    {
        public bool Value { get; set; }
        public string Redirect { get; set; }
        public string Message { get; set; }
        public string CurrentID { get; set; }
    }
}
