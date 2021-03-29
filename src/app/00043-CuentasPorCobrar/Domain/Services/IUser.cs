using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Domain.Helpers;

namespace Domain.Services
{
    public interface IUser
    {
        List<User> Find();
        User Get(int userId);
        Response GetUserState(string UserName);
        Response ChangeState(User userRegister, int currentUserId);
        Response Save(User userRegister, int currentUserId, SaveOption saveOption);
    }
}
