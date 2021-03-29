using Domain.Helpers;
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

            foreach (var item in _user.Find())
            {
                result.Add(new UserViewModel(item));
            }

            return result;
        }

        public UserRegisterViewModel Find(int userId)
        {
            return new UserRegisterViewModel(_user.Get(userId));
        }

        public Response GetUserState(string username)
        {
            return _user.GetUserState(username);
        }


        public Response ChangeState(int userId, bool stateValue, int currentUserId, string returnUrl)
        {
            User userRegister = new User()
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
            User user = new User()
            {
                UserId = userRegisterViewModel.UserId,
                UserName = userRegisterViewModel.UserName,
                Person = new Persona()
                {
                    Id = userRegisterViewModel.PersonId,
                    Nombre = userRegisterViewModel.PersonName,
                    correo = userRegisterViewModel.Email,
                },
                Rol = new RolAplicacion()
                {
                    Id = userRegisterViewModel.RoleId,
                },
                Dependencia = new Dependencia()
                {
                    Id = userRegisterViewModel.DependenciaId
                }
            };

            Response result = _user.Save(user, currentUserId, userRegisterViewModel.UserId.HasValue ? SaveOption.Update : SaveOption.Insert);

            if (result.Value)
            {
                result.Success(false);
            }
            else
            {
                result.Error(true);
            }

            return result;
        }
    }
}