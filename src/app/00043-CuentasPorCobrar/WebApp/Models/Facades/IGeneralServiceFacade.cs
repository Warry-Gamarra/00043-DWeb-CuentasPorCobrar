﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public interface IGeneralServiceFacade
    {
        IEnumerable<SelectViewModel> Listar_Anios();

        IEnumerable<SelectViewModel> Listar_TipoEstudios();
    }
}