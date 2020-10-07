using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class User: IUser
    {
        public int? UserId { get; set; }
        public string UserName { get; set; }
        public bool Enabled { get; set; }


        public User() { }


        public List<User> Find()
        {
            throw new NotImplementedException();
        }

        public User Get(int userId)
        {
            throw new NotImplementedException();
        }

        public Response ChangeState(User userRegister, int currentUserId)
        {
            throw new NotImplementedException();
        }

        public Response Save(User userRegister, int currentUserId, SaveOption saveOption)
        {
            throw new NotImplementedException();
        }
    }
}
