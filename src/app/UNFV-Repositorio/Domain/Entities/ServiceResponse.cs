using Data.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class ServiceResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string CurrentID { get; set; }

        public ServiceResponse() { }

        public ServiceResponse(ResponseData responseData)
        {
            this.Success = responseData.Value;
            this.Message = responseData.Message;
            this.CurrentID = responseData.CurrentID;
        }
    }
}
