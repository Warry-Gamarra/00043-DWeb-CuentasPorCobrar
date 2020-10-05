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
        public int? UserId { get; private set; }
        public string UserName { get; private set; }

        public User() { }

        public User(UserRegister userRegister)
        {
            this.UserId = userRegister.UserId;
            this.UserName = userRegister.UserName;
        }


        public List<User> Find()
        {
            throw new NotImplementedException();
        }

        public User Get(int userId)
        {
            throw new NotImplementedException();
        }

        public Response ChangeState(UserRegister userRegister, int currentUserId)
        {
            throw new NotImplementedException();
        }

        public Response Save(UserRegister userRegister, int currentUserId, SaveOption saveOption)
        {
            throw new NotImplementedException();
        }
    }
}
