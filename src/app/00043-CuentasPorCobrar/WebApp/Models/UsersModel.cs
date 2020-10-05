using Domain.DTO;
using Domain.Services;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models
{

    public class UsersModel
    {
        private readonly IUser _user;

        public UsersModel()
        {
            _user = new User();
        }

        public List<UserViewModel> Find()
        {
            List<UserViewModel> result = new List<UserViewModel>();
            List<User> data = _user.Find();

            return result;
        }

        public UserRegisterViewModel Find(int userId)
        {
            UserRegisterViewModel result = new UserRegisterViewModel();
            User data = _user.Get(userId);

            return result;
        }

        public Response ChangeState(int userId, bool stateValue, int currentUserId, string returnUrl)
        {
            UserRegister userRegister = new UserRegister()
            {
                UserId = userId,
                Enabled = stateValue
            };

            Response result = _user.ChangeState(userRegister, currentUserId);
            result.Action = returnUrl;

            if (result.Value)
            {
                ResponseModel.Success(result, string.Empty, false);
            }
            else
            {
                ResponseModel.Error(result);
            }

            return result;
        }

        public Response Save(UserRegisterViewModel userRegisterViewModel, int currentUserId)
        {
            UserRegister userRegister = new UserRegister()
            {
                UserId = userRegisterViewModel.UserId,
                UserName = userRegisterViewModel.UserName
            };

            Response result = _user.Save(userRegister, currentUserId, userRegisterViewModel.UserId.HasValue ? SaveOption.Update : SaveOption.Insert);

            if (result.Value)
            {
                ResponseModel.Success(result, string.Empty, false);
            }
            else
            {
                ResponseModel.Error(result);
            }

            return result;
        }
    }
}