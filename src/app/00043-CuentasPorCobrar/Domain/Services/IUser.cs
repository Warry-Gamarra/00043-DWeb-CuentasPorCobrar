using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IUser
    {
        List<User> Find();
        User Get(int userId);
        Response ChangeState(UserRegister userRegister, int currentUserId);
        Response Save(UserRegister userRegister, int currentUserId, SaveOption saveOption);
    }
}
